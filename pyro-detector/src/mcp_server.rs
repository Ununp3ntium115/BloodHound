use anyhow::{Context, Result};
use serde_json::{json, Value};
use std::io::{self, BufRead, BufReader, Write};

use crate::api::PyroApiClient;
use crate::cdif::CdifCompliance;
use crate::config::DetectorConfig;
use crate::logging::{LogLevel, Logger};
use crate::types::*;

/// PYRO Detector MCP Server
/// 
/// Acts as a "detonator" service - a 3rd party package that integrates
/// with PYRO Platform Ignition via MCP protocol.
pub struct PyroDetectorServer {
    api_client: PyroApiClient,
    config: DetectorConfig,
    cdif: CdifCompliance,
    logger: Logger,
}

impl PyroDetectorServer {
    /// Create new MCP server
    pub fn new(config: DetectorConfig) -> Result<Self> {
        let api_client = PyroApiClient::new(config.clone())?;
        let cdif = CdifCompliance::new();
        let log_level = std::env::var("PYRO_LOG_LEVEL")
            .ok()
            .and_then(|s| match s.to_uppercase().as_str() {
                "ERROR" => Some(LogLevel::Error),
                "WARN" => Some(LogLevel::Warn),
                "INFO" => Some(LogLevel::Info),
                "DEBUG" => Some(LogLevel::Debug),
                "TRACE" => Some(LogLevel::Trace),
                _ => None,
            })
            .unwrap_or(LogLevel::Info);
        let logger = Logger::new(log_level);

        Ok(Self {
            api_client,
            config,
            cdif,
            logger,
        })
    }

    /// Run the MCP server (stdio-based)
    pub async fn run(&mut self) -> Result<()> {
        let stdin = io::stdin();
        let mut reader = BufReader::new(stdin.lock());
        let mut stdout = io::stdout();

        loop {
            let mut line = String::new();
            reader.read_line(&mut line)?;

            if line.is_empty() {
                break;
            }

            let request: Value = serde_json::from_str(&line)
                .context("Failed to parse request")?;

            let response = self.handle_request(&request).await?;

            writeln!(stdout, "{}", serde_json::to_string(&response)?)?;
            stdout.flush()?;
        }

        Ok(())
    }

    /// Handle MCP request
    async fn handle_request(&mut self, request: &Value) -> Result<Value> {
        let method = request["method"]
            .as_str()
            .context("Missing method")?;
        let params_owned = request.get("params").cloned().unwrap_or_else(|| json!({}));
        let params = &params_owned;

        self.logger.debug(&format!("Handling MCP method: {}", method));

        let result = match method {
            // Investigation methods
            "pyro_list_detonators" => self.handle_list_detonators(params).await?,
            "pyro_execute_detonator" => self.handle_execute_detonator(params).await?,
            "pyro_create_case" => self.handle_create_case(params).await?,
            
            // Agent methods
            "pyro_list_agents" => self.handle_list_agents(params).await?,
            
            // Query methods
            "pyro_execute_pql" => self.handle_execute_pql(params).await?,
            
            // System methods
            "pyro_health" => self.handle_health(params).await?,
            "pyro_authenticate" => self.handle_authenticate(params).await?,
            
            _ => json!({
                "error": {
                    "code": "METHOD_NOT_FOUND",
                    "message": format!("Unknown method: {}", method)
                }
            }),
        };

        Ok(json!({
            "jsonrpc": "2.0",
            "id": request.get("id"),
            "result": result,
        }))
    }

    /// List available detonators
    async fn handle_list_detonators(&mut self, params: &Value) -> Result<Value> {
        let investigation_type = params.get("investigation_type").and_then(|v| v.as_str());
        let platform = params.get("platform").and_then(|v| v.as_str());
        let category = params.get("category").and_then(|v| v.as_str());

        let detonators = self
            .api_client
            .list_detonators(investigation_type, platform, category)
            .await?;

        Ok(json!({
            "detonators": detonators,
            "count": detonators.len(),
        }))
    }

    /// Execute a detonator
    async fn handle_execute_detonator(&mut self, params: &Value) -> Result<Value> {
        let request: DetonatorExecutionRequest = serde_json::from_value(
            params.clone()
        ).context("Invalid detonator execution request")?;

        // CDIF compliance check
        if self.config.cdif_compliance {
            if let Err(errors) = self.cdif.validate(&serde_json::to_value(&request)?) {
                return Ok(json!({
                    "error": {
                        "code": "CDIF_COMPLIANCE_ERROR",
                        "message": "CDIF compliance validation failed",
                        "details": errors
                    }
                }));
            }
        }

        let result = self.api_client.execute_detonator(request).await?;

        Ok(json!({
            "execution": result,
            "success": true,
        }))
    }

    /// Create investigation case
    async fn handle_create_case(&mut self, params: &Value) -> Result<Value> {
        let case: InvestigationCase = serde_json::from_value(
            params.clone()
        ).context("Invalid case creation request")?;

        let result = self.api_client.create_case(case).await?;

        Ok(json!({
            "case": result,
            "success": true,
        }))
    }

    /// List agents
    async fn handle_list_agents(&mut self, _params: &Value) -> Result<Value> {
        let agents = self.api_client.list_agents().await?;

        Ok(json!({
            "agents": agents,
            "count": agents.len(),
        }))
    }

    /// Execute PQL query
    async fn handle_execute_pql(&mut self, params: &Value) -> Result<Value> {
        let request: PqlQueryRequest = serde_json::from_value(
            params.clone()
        ).context("Invalid PQL query request")?;

        let result = self.api_client.execute_pql_query(request).await?;

        Ok(json!({
            "query": result,
            "success": true,
        }))
    }

    /// Get system health
    async fn handle_health(&mut self, _params: &Value) -> Result<Value> {
        let health = self.api_client.get_health().await?;

        Ok(json!({
            "health": health,
            "success": true,
        }))
    }

    /// Authenticate
    async fn handle_authenticate(&mut self, _params: &Value) -> Result<Value> {
        let token = self.api_client.authenticate().await?;

        Ok(json!({
            "token": token,
            "success": true,
        }))
    }
}


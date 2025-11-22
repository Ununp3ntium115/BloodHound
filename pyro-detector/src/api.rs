use anyhow::{Context, Result};
use reqwest::Client;
use serde_json::json;
use std::time::Duration;

use crate::config::DetectorConfig;
use crate::types::*;

/// PYRO Platform Ignition API Client
pub struct PyroApiClient {
    client: Client,
    config: DetectorConfig,
    token: Option<String>,
}

impl PyroApiClient {
    /// Create new API client
    pub fn new(config: DetectorConfig) -> Result<Self> {
        let client = Client::builder()
            .timeout(Duration::from_secs(config.timeout_seconds))
            .build()
            .context("Failed to create HTTP client")?;

        Ok(Self {
            client,
            config,
            token: None,
        })
    }

    /// Authenticate and get token
    pub async fn authenticate(&mut self) -> Result<String> {
        // Try to use existing token
        if let Some(token) = &self.token {
            return Ok(token.clone());
        }

        // Try to use config token
        if let Some(token) = &self.config.api_token {
            self.token = Some(token.clone());
            return Ok(token.clone());
        }

        // Login with username/password
        if let (Some(_username), Some(_password)) = (&self.config.username, &self.config.password) {
            let response = self
                .client
                .post(&format!("{}/api/auth/login", self.config.pyro_api_url))
                .json(&json!({
                    "username": _username,
                    "password": _password
                }))
                .send()
                .await
                .context("Failed to send login request")?;

            if !response.status().is_success() {
                anyhow::bail!("Login failed: {}", response.status());
            }

            let result: serde_json::Value = response
                .json()
                .await
                .context("Failed to parse login response")?;

            let token = result["token"]
                .as_str()
                .context("No token in login response")?
                .to_string();

            self.token = Some(token.clone());
            return Ok(token);
        }

        anyhow::bail!("No authentication credentials available");
    }

    /// Get authorization header
    async fn get_auth_header(&mut self) -> Result<String> {
        let token = self.authenticate().await?;
        Ok(format!("Bearer {}", token))
    }

    /// List all available detonators
    pub async fn list_detonators(
        &mut self,
        investigation_type: Option<&str>,
        platform: Option<&str>,
        category: Option<&str>,
    ) -> Result<Vec<Detonator>> {
        let mut url = format!("{}/api/v2/fire-marshal/investigation/detonators", self.config.pyro_api_url);
        let mut query_params = vec![];

        if let Some(it) = investigation_type {
            query_params.push(("investigation_type", it));
        }
        if let Some(p) = platform {
            query_params.push(("platform", p));
        }
        if let Some(c) = category {
            query_params.push(("category", c));
        }

        let response = self
            .client
            .get(&url)
            .query(&query_params)
            .header("Authorization", self.get_auth_header().await?)
            .send()
            .await
            .context("Failed to list detonators")?;

        if !response.status().is_success() {
            anyhow::bail!("Failed to list detonators: {}", response.status());
        }

        let result: serde_json::Value = response.json().await?;
        let detonators: Vec<Detonator> = serde_json::from_value(
            result["detonators"].clone()
        ).context("Failed to parse detonators")?;

        Ok(detonators)
    }

    /// Execute a detonator
    pub async fn execute_detonator(
        &mut self,
        request: DetonatorExecutionRequest,
    ) -> Result<DetonatorExecutionResult> {
        let url = format!(
            "{}/api/v2/fire-marshal/investigation/detonators/execute",
            self.config.pyro_api_url
        );

        let response = self
            .client
            .post(&url)
            .header("Authorization", self.get_auth_header().await?)
            .json(&request)
            .send()
            .await
            .context("Failed to execute detonator")?;

        let status = response.status();
        if !status.is_success() {
            let error_text = response.text().await.unwrap_or_else(|_| format!("HTTP {}", status));
            let error: ApiError = serde_json::from_str(&error_text).unwrap_or_else(|_| ApiError {
                error: ErrorDetails {
                    code: "UNKNOWN_ERROR".to_string(),
                    message: format!("HTTP {}", status),
                    details: Some(error_text),
                    timestamp: None,
                    trace_id: None,
                },
                investigation_context: None,
            });
            anyhow::bail!("Detonator execution failed: {}", error.error.message);
        }

        let result: DetonatorExecutionResult = response
            .json()
            .await
            .context("Failed to parse execution result")?;

        Ok(result)
    }

    /// Create investigation case
    pub async fn create_case(&mut self, case: InvestigationCase) -> Result<InvestigationCase> {
        let url = format!(
            "{}/api/v2/fire-marshal/investigation/cases/create",
            self.config.pyro_api_url
        );

        let response = self
            .client
            .post(&url)
            .header("Authorization", self.get_auth_header().await?)
            .json(&case)
            .send()
            .await
            .context("Failed to create case")?;

        if !response.status().is_success() {
            anyhow::bail!("Failed to create case: {}", response.status());
        }

        let result: InvestigationCase = response
            .json()
            .await
            .context("Failed to parse case response")?;

        Ok(result)
    }

    /// List agents
    pub async fn list_agents(&mut self) -> Result<Vec<Agent>> {
        let url = format!("{}/api/agents", self.config.pyro_api_url);

        let response = self
            .client
            .get(&url)
            .header("Authorization", self.get_auth_header().await?)
            .send()
            .await
            .context("Failed to list agents")?;

        if !response.status().is_success() {
            anyhow::bail!("Failed to list agents: {}", response.status());
        }

        let agents: Vec<Agent> = response
            .json()
            .await
            .context("Failed to parse agents")?;

        Ok(agents)
    }

    /// Execute PQL query
    pub async fn execute_pql_query(
        &mut self,
        request: PqlQueryRequest,
    ) -> Result<PqlQueryResult> {
        let url = format!("{}/api/pql/query", self.config.pyro_api_url);

        let response = self
            .client
            .post(&url)
            .header("Authorization", self.get_auth_header().await?)
            .json(&request)
            .send()
            .await
            .context("Failed to execute PQL query")?;

        if !response.status().is_success() {
            anyhow::bail!("Failed to execute PQL query: {}", response.status());
        }

        let result: PqlQueryResult = response
            .json()
            .await
            .context("Failed to parse PQL query result")?;

        Ok(result)
    }

    /// Get system health
    pub async fn get_health(&mut self) -> Result<serde_json::Value> {
        let url = format!(
            "{}/api/v2/fire-marshal/admin/health",
            self.config.pyro_api_url
        );

        let response = self
            .client
            .get(&url)
            .header("Authorization", self.get_auth_header().await?)
            .send()
            .await
            .context("Failed to get health")?;

        if !response.status().is_success() {
            anyhow::bail!("Failed to get health: {}", response.status());
        }

        let result: serde_json::Value = response
            .json()
            .await
            .context("Failed to parse health response")?;

        Ok(result)
    }
}


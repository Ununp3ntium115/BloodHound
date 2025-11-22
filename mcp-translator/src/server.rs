use anyhow::{Context, Result};
use serde_json::{json, Value};
use std::io::{self, BufRead, BufReader, Write};

use crate::agents::{AgentRegistry, generate_implementation_plan};
use crate::gap_analysis::GapAnalyzer;
use crate::parser::{CodeParser, Language};
use crate::translator::CryptexTranslator;

/// MCP Server for translating source code to Cryptex structure
pub struct McpTranslatorServer {
    parser: CodeParser,
    translator: CryptexTranslator,
    gap_analyzer: GapAnalyzer,
    agent_registry: Option<AgentRegistry>,
}

impl McpTranslatorServer {
    /// Create new MCP translator server
    pub fn new() -> Result<Self> {
        let parser = CodeParser::new();
        let translator = CryptexTranslator::new()?;
        let gap_analyzer = GapAnalyzer::new();

        Ok(Self {
            parser,
            translator,
            gap_analyzer,
            agent_registry: None,
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

            let request: Value = serde_json::from_str(&line).context("Failed to parse request")?;

            let response = self.handle_request(&request).await?;

            writeln!(stdout, "{}", serde_json::to_string(&response)?)?;
            stdout.flush()?;
        }

        Ok(())
    }

    /// Handle MCP request
    async fn handle_request(&mut self, request: &Value) -> Result<Value> {
        let method = request["method"].as_str().context("Missing method")?;
        let params_owned = request.get("params").cloned().unwrap_or_else(|| json!({}));
        let params = &params_owned;

        let result = match method {
            "translate_file" => self.handle_translate_file(params).await?,
            "translate_directory" => self.handle_translate_directory(params).await?,
            "analyze_codebase" => self.handle_analyze_codebase(params).await?,
            "extract_functions" => self.handle_extract_functions(params).await?,
            "gap_analysis" => self.handle_gap_analysis(params).await?,
            "create_agents" => self.handle_create_agents(params).await?,
            "get_agents" => self.handle_get_agents(params).await?,
            "get_roadmap" => self.handle_get_roadmap(params).await?,
            "get_implementation_plan" => self.handle_get_implementation_plan(params).await?,
            "update_task_status" => self.handle_update_task_status(params).await?,
            _ => json!({
                "error": format!("Unknown method: {}", method)
            }),
        };

        Ok(json!({
            "jsonrpc": "2.0",
            "id": request.get("id"),
            "result": result,
        }))
    }

    /// Handle translate_file request
    async fn handle_translate_file(&mut self, params: &Value) -> Result<Value> {
        // Reset translator state for new translation
        self.translator = CryptexTranslator::new()?;
        let file_path = params["file_path"].as_str().context("Missing file_path")?;
        let language_str = params["language"].as_str().context("Missing language")?;
        let cryptex_path = params["cryptex_path"]
            .as_str()
            .context("Missing cryptex_path")?;

        let language = Language::from_str(language_str)?;

        // Parse the file
        let functions = self.parser.parse_file(file_path, &language)?;

        // Translate to Cryptex
        let result = self
            .translator
            .translate_functions(&functions, cryptex_path, None)?;

        Ok(json!({
            "success": true,
            "functions_translated": result.len(),
            "cryptex_path": cryptex_path,
            "functions": result,
        }))
    }

    /// Handle translate_directory request
    async fn handle_translate_directory(&mut self, params: &Value) -> Result<Value> {
        // Reset translator state for new translation
        self.translator = CryptexTranslator::new()?;
        let dir_path = params["directory_path"]
            .as_str()
            .context("Missing directory_path")?;
        let language_str = params["language"].as_str().context("Missing language")?;
        let cryptex_path = params["cryptex_path"]
            .as_str()
            .context("Missing cryptex_path")?;
        let recursive = params["recursive"].as_bool().unwrap_or(true);

        let language = Language::from_str(language_str)?;

        // Parse directory
        let functions = self
            .parser
            .parse_directory(dir_path, &language, recursive)?;

        // Translate to Cryptex
        let result = self
            .translator
            .translate_functions(&functions, cryptex_path, None)?;

        Ok(json!({
            "success": true,
            "functions_translated": result.len(),
            "cryptex_path": cryptex_path,
            "total_files": self.parser.get_files_processed(),
        }))
    }

    /// Handle analyze_codebase request
    async fn handle_analyze_codebase(&mut self, params: &Value) -> Result<Value> {
        let dir_path = params["directory_path"]
            .as_str()
            .context("Missing directory_path")?;
        let language_str = params["language"].as_str().context("Missing language")?;

        let language = Language::from_str(language_str)?;

        // Analyze codebase
        let analysis = self.parser.analyze_codebase(dir_path, &language)?;

        Ok(json!({
            "total_files": analysis.total_files,
            "total_functions": analysis.total_functions,
            "function_relationships": analysis.relationships,
            "packages": analysis.packages,
        }))
    }

    /// Handle extract_functions request
    async fn handle_extract_functions(&mut self, params: &Value) -> Result<Value> {
        let file_path = params["file_path"].as_str().context("Missing file_path")?;
        let language_str = params["language"].as_str().context("Missing language")?;

        let language = Language::from_str(language_str)?;

        // Extract functions
        let functions = self.parser.parse_file(file_path, &language)?;

        Ok(json!({
            "functions": functions.iter().map(|f| json!({
                "name": f.name,
                "signature": f.signature,
                "file": f.file_path.display().to_string(),
                "line": f.line_number,
            })).collect::<Vec<_>>(),
        }))
    }

    /// Handle gap_analysis request
    pub async fn handle_gap_analysis(&mut self, params: &Value) -> Result<Value> {
        let go_path = params["go_source_path"]
            .as_str()
            .context("Missing go_source_path")?;
        let rust_path = params["rust_source_path"]
            .as_str()
            .context("Missing rust_source_path")?;

        // Perform gap analysis
        let analysis = self.gap_analyzer.analyze(go_path, rust_path)?;

        Ok(json!({
            "coverage_percent": analysis.coverage_percent,
            "total_source_functions": analysis.source_functions.len(),
            "total_rust_functions": analysis.rust_functions.len(),
            "missing_functions": analysis.missing_functions.len(),
            "extra_functions": analysis.extra_functions.len(),
            "missing": analysis.missing_functions.iter().map(|f| json!({
                "name": f.name,
                "module": f.module,
                "file": f.file_path,
                "signature": f.signature,
            })).collect::<Vec<_>>(),
            "modules": analysis.modules,
        }))
    }

    /// Handle create_agents request - creates agents from gap analysis
    pub async fn handle_create_agents(&mut self, params: &Value) -> Result<Value> {
        let go_path = params["go_source_path"]
            .as_str()
            .context("Missing go_source_path")?;
        let rust_path = params["rust_source_path"]
            .as_str()
            .context("Missing rust_source_path")?;

        // Perform gap analysis
        let analysis = self.gap_analyzer.analyze(go_path, rust_path)?;

        // Create agent registry from analysis
        let registry = AgentRegistry::from_gap_analysis(&analysis);
        let agent_count = registry.get_all_agents().len();
        let agents_data: Vec<_> = registry.get_all_agents()
            .iter()
            .map(|a| json!({
                "name": a.name,
                "module": a.module,
                "status": format!("{:?}", a.status),
                "priority": format!("{:?}", a.priority),
                "progress": a.progress,
                "total_tasks": a.tasks.len(),
            }))
            .collect();

        // Store registry
        self.agent_registry = Some(registry);

        Ok(json!({
            "success": true,
            "agents_created": agent_count,
            "agents": agents_data,
        }))
    }

    /// Handle get_agents request
    pub async fn handle_get_agents(&mut self, params: &Value) -> Result<Value> {
        let registry = self.agent_registry.as_ref()
            .context("No agents created. Call create_agents first.")?;

        let module_filter = params.get("module").and_then(|v| v.as_str());

        let agents = if let Some(module) = module_filter {
            vec![registry.get_agent(module).context("Agent not found")?]
        } else {
            registry.get_all_agents()
        };

        Ok(json!({
            "agents": agents.iter().map(|a| json!({
                "name": a.name,
                "module": a.module,
                "status": format!("{:?}", a.status),
                "priority": format!("{:?}", a.priority),
                "progress": a.progress,
                "tasks": a.tasks.iter().map(|t| json!({
                    "id": t.id,
                    "description": t.description,
                    "status": format!("{:?}", t.status),
                    "functions": t.functions,
                })).collect::<Vec<_>>(),
            })).collect::<Vec<_>>(),
        }))
    }

    /// Handle get_roadmap request
    pub async fn handle_get_roadmap(&mut self, _params: &Value) -> Result<Value> {
        let registry = self.agent_registry.as_ref()
            .context("No agents created. Call create_agents first.")?;

        let roadmap = registry.get_roadmap();

        Ok(json!({
            "critical": roadmap.critical,
            "high": roadmap.high,
            "medium": roadmap.medium,
            "low": roadmap.low,
        }))
    }

    /// Handle get_implementation_plan request
    pub async fn handle_get_implementation_plan(&mut self, params: &Value) -> Result<Value> {
        let module = params["module"].as_str().context("Missing module")?;
        let go_path = params["go_source_path"]
            .as_str()
            .context("Missing go_source_path")?;
        let rust_path = params["rust_source_path"]
            .as_str()
            .context("Missing rust_source_path")?;

        // Perform gap analysis
        let analysis = self.gap_analyzer.analyze(go_path, rust_path)?;

        // Generate implementation plan
        let plan = generate_implementation_plan(module, &analysis)?;

        Ok(json!({
            "module": plan.module,
            "total_functions": plan.total_functions,
            "missing_functions": plan.missing_functions,
            "coverage": plan.coverage,
            "phases": plan.phases,
            "file_groups": plan.file_groups,
        }))
    }

    /// Handle update_task_status request
    pub async fn handle_update_task_status(&mut self, params: &Value) -> Result<Value> {
        let registry = self.agent_registry.as_mut()
            .context("No agents created. Call create_agents first.")?;

        let module = params["module"].as_str().context("Missing module")?;
        let task_id = params["task_id"].as_str().context("Missing task_id")?;
        let status_str = params["status"].as_str().context("Missing status")?;

        let status = match status_str {
            "NotStarted" => crate::agents::TaskStatus::NotStarted,
            "InProgress" => crate::agents::TaskStatus::InProgress,
            "Completed" => crate::agents::TaskStatus::Completed,
            "Blocked" => crate::agents::TaskStatus::Blocked,
            _ => return Err(anyhow::anyhow!("Invalid status: {}", status_str)),
        };

        registry.update_task_status(module, task_id, status)?;

        let agent = registry.get_agent(module).context("Agent not found")?;

        Ok(json!({
            "success": true,
            "agent": {
                "name": agent.name,
                "module": agent.module,
                "status": format!("{:?}", agent.status),
                "progress": agent.progress,
            }
        }))
    }
}

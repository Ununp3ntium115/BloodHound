use axum::{
    extract::{Path, State},
    http::StatusCode,
    response::{IntoResponse, Json},
};
use cryptex::Cryptex;
use node_red_bridge::NodeRedMessage;
use serde::{Deserialize, Serialize};
use serde_json::{json, Value};

use super::state::AppState;
pub use crate::auth::handlers::{api_login_with_secret, api_logout, api_validate_session};
use crate::data_extractor::BloodHoundExtractor;
use pyro_core::pipeline::{PipelineRecord, PipelineRegistry};

/// Root endpoint - display Pyro info
pub async fn root() -> impl IntoResponse {
    Json(json!({
        "name": "BloodSniffer - Autonomous Data Liberation System",
        "version": "0.1.0",
        "tagline": "No gods, no masters, only autonomous systems",
        "endpoints": [
            "GET /health",
            "POST /api/cryptex",
            "GET /api/cryptex/:path",
            "POST /api/extract",
            "POST /api/pipeline",
        ]
    }))
}

/// Health check endpoint
pub async fn health() -> impl IntoResponse {
    Json(json!({
        "status": "active",
        "icon": "🩸",
    }))
}

#[derive(Debug, Deserialize)]
pub struct CreateCryptexRequest {
    pub parent_function: Option<String>,
    pub name: String,
    pub function_code: String,
    pub pseudocode: String,
}

#[derive(Debug, Serialize)]
pub struct CreateCryptexResponse {
    pub path_name: String,
    pub name: String,
    pub message: String,
}

/// Create new function in Cryptex structure
pub async fn create_cryptex(
    State(state): State<AppState>,
    Json(req): Json<CreateCryptexRequest>,
) -> Result<Json<CreateCryptexResponse>, StatusCode> {
    // Create or load Cryptex
    let cryptex_path = state.cryptex_root.join("main");
    let mut cryptex = Cryptex::new(&cryptex_path).map_err(|_| StatusCode::INTERNAL_SERVER_ERROR)?;

    // Add function to cryptex
    let node = cryptex
        .add_function(
            req.parent_function.clone(),
            req.name.clone(),
            req.function_code.clone(),
            req.pseudocode.clone(),
        )
        .map_err(|_| StatusCode::INTERNAL_SERVER_ERROR)?;

    Ok(Json(CreateCryptexResponse {
        path_name: node.path_name.clone(),
        name: node.name.clone(),
        message: "Function added to cryptex structure successfully".to_string(),
    }))
}

#[derive(Debug, Serialize)]
pub struct GetCryptexResponse {
    pub name: String,
    pub path_name: String,
    pub parent: Option<String>,
    pub children: Vec<String>,
    pub function_code: String,
    pub pseudocode: String,
}

/// Get function from Cryptex by path name
pub async fn get_cryptex(
    State(state): State<AppState>,
    Path(path_name): Path<String>,
) -> Result<Json<GetCryptexResponse>, StatusCode> {
    let cryptex_path = state.cryptex_root.join("main");
    let cryptex = Cryptex::new(&cryptex_path).map_err(|_| StatusCode::INTERNAL_SERVER_ERROR)?;

    let node = cryptex
        .get_function(&path_name)
        .map_err(|_| StatusCode::INTERNAL_SERVER_ERROR)?
        .ok_or(StatusCode::NOT_FOUND)?;

    Ok(Json(GetCryptexResponse {
        name: node.name,
        path_name: node.path_name,
        parent: node.parent,
        children: node.children,
        function_code: node.function_code,
        pseudocode: node.pseudocode,
    }))
}

#[derive(Debug, Deserialize)]
pub struct ExtractRequest {
    pub data: Value,
}

#[derive(Debug, Serialize)]
pub struct ExtractResponse {
    pub nodes_count: usize,
    pub edges_count: usize,
    pub functions_created: Vec<String>,
}

/// Extract data from BloodHound format and create functions in Cryptex
pub async fn extract_data(
    State(state): State<AppState>,
    Json(req): Json<ExtractRequest>,
) -> Result<Json<ExtractResponse>, StatusCode> {
    // Extract data
    let extracted =
        BloodHoundExtractor::extract_from_json(&req.data).map_err(|_| StatusCode::BAD_REQUEST)?;

    // Create Cryptex for extraction
    let cryptex_path = state.cryptex_root.join("extracted");
    let mut cryptex = Cryptex::new(&cryptex_path).map_err(|_| StatusCode::INTERNAL_SERVER_ERROR)?;

    let mut functions_created = Vec::new();

    // Create function for parsing nodes
    let nodes_code = format!(
        "fn parse_nodes(data: &Value) -> Result<Vec<Node>> {{\n    // Parse nodes from BloodHound data\n    todo!()\n}}"
    );
    let nodes_pseudo = "Parse nodes from BloodHound JSON data structure".to_string();
    let nodes_node = cryptex
        .add_function(None, "parse_nodes".to_string(), nodes_code, nodes_pseudo)
        .map_err(|_| StatusCode::INTERNAL_SERVER_ERROR)?;
    functions_created.push(nodes_node.path_name.clone());

    // Create function for parsing edges
    let edges_code = format!(
        "fn parse_edges(data: &Value) -> Result<Vec<Edge>> {{\n    // Parse edges/relationships from BloodHound data\n    todo!()\n}}"
    );
    let edges_pseudo = "Parse edges/relationships from BloodHound JSON data structure".to_string();
    let edges_node = cryptex
        .add_function(
            Some(nodes_node.path_name.clone()),
            "parse_edges".to_string(),
            edges_code,
            edges_pseudo,
        )
        .map_err(|_| StatusCode::INTERNAL_SERVER_ERROR)?;
    functions_created.push(edges_node.path_name.clone());

    // Create function for processing extracted data
    let process_code = format!(
        "fn process_extracted_data(nodes: Vec<Node>, edges: Vec<Edge>) -> Result<ProcessedData> {{\n    // Process extracted nodes and edges\n    todo!()\n}}"
    );
    let process_pseudo = "Process extracted nodes and edges into final data structure".to_string();
    let process_node = cryptex
        .add_function(
            Some(edges_node.path_name.clone()),
            "process_extracted_data".to_string(),
            process_code,
            process_pseudo,
        )
        .map_err(|_| StatusCode::INTERNAL_SERVER_ERROR)?;
    functions_created.push(process_node.path_name.clone());

    // Send to Node-RED
    let message = NodeRedMessage::new(
        "bloodsniffer/extraction".to_string(),
        json!({
            "functions_created": functions_created.len(),
            "nodes": extracted.nodes.len(),
            "edges": extracted.edges.len(),
        }),
    );

    let node_red = state.node_red.read().await;
    let _ = node_red.send(message).await;

    Ok(Json(ExtractResponse {
        nodes_count: extracted.nodes.len(),
        edges_count: extracted.edges.len(),
        functions_created,
    }))
}

#[derive(Debug, Deserialize)]
pub struct CreatePipelineRequest {
    pub pipeline_id: Option<String>,
    pub source: String,
    pub transformers: Vec<String>,
    pub destination: String,
    pub payload: Value,
}

#[derive(Debug, Serialize)]
pub struct CreatePipelineResponse {
    pub pipeline_id: String,
    pub message: String,
    pub file_path: String,
}

/// Create data pipeline
pub async fn create_pipeline(
    State(state): State<AppState>,
    Json(req): Json<CreatePipelineRequest>,
) -> Result<Json<CreatePipelineResponse>, StatusCode> {
    if req.transformers.is_empty() {
        return Err(StatusCode::BAD_REQUEST);
    }

    let pipeline_id = req
        .pipeline_id
        .unwrap_or_else(PipelineRegistry::generate_id);
    let registry = PipelineRegistry::new(&state.config.pipeline.work_dir);
    let record = PipelineRecord::new(
        pipeline_id.clone(),
        req.source.clone(),
        req.transformers.clone(),
        req.destination.clone(),
        req.payload.clone(),
    );

    let file_path = registry
        .persist(&record)
        .map_err(|_| StatusCode::INTERNAL_SERVER_ERROR)?;

    {
        let node_red = state.node_red.read().await;
        let _ = node_red
            .send(NodeRedMessage::new(
                "bloodsniffer/pipelines".to_string(),
                json!({
                    "event": "pipeline_queued",
                    "pipeline_id": pipeline_id,
                    "source": record.source,
                    "destination": record.destination,
                    "transformers": record.transformers,
                    "file": file_path.display().to_string(),
                    "queued_at": record.created_at,
                }),
            ))
            .await;
    }

    Ok(Json(CreatePipelineResponse {
        pipeline_id,
        message: "Pipeline queued successfully".to_string(),
        file_path: file_path.display().to_string(),
    }))
}

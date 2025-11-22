use axum::{
    extract::State,
    http::StatusCode,
    response::{IntoResponse, Json},
};
use node_red_bridge::NodeRedMessage;
use serde_json::{json, Value};

use super::state::AppState;

/// Root endpoint
pub async fn root() -> impl IntoResponse {
    Json(json!({
        "name": "Fire Marshal - Data Flow Orchestration",
        "version": "0.1.0",
        "tagline": "Watching over autonomous data pipelines",
        "endpoints": [
            "GET /health",
            "GET /api/monitor",
            "POST /api/orchestrate",
        ]
    }))
}

/// Health check endpoint
pub async fn health() -> impl IntoResponse {
    Json(json!({
        "status": "on patrol",
        "icon": "🚒",
    }))
}

/// Get monitoring data
pub async fn get_monitoring(
    State(state): State<AppState>,
) -> Result<Json<serde_json::Value>, StatusCode> {
    let monitor = state.monitor.read().await;
    let stats = monitor.get_stats();

    Ok(Json(json!({
        "pipelines_active": stats.active_pipelines,
        "data_processed": stats.data_processed,
        "errors": stats.errors,
        "last_update": stats.last_update,
    })))
}

#[derive(serde::Deserialize)]
pub struct OrchestrateRequest {
    pub pipeline_id: String,
    pub source: String,
    pub destination: String,
    pub payload: Value,
}

/// Orchestrate data flow
pub async fn orchestrate(
    State(state): State<AppState>,
    Json(req): Json<OrchestrateRequest>,
) -> Result<Json<serde_json::Value>, StatusCode> {
    let mut orchestrator = state.orchestrator.write().await;

    let run_stats = orchestrator
        .create_pipeline(
            &req.pipeline_id,
            &req.source,
            &req.destination,
            &req.payload,
        )
        .map_err(|_| StatusCode::INTERNAL_SERVER_ERROR)?;
    let active_count = orchestrator.active_pipeline_count();
    drop(orchestrator);

    {
        let mut monitor = state.monitor.write().await;
        monitor.set_active_pipelines(active_count);
        monitor.increment_data((run_stats.nodes_count + run_stats.edges_count) as u64);
    }

    {
        let node_red = state.node_red.read().await;
        let message = NodeRedMessage::new(
            "fire-marshal/pipelines".to_string(),
            json!({
                "pipeline_id": req.pipeline_id,
                "source": req.source,
                "destination": req.destination,
                "nodes": run_stats.nodes_count,
                "edges": run_stats.edges_count,
                "processed_at": run_stats.processed_at,
            }),
        );
        let _ = node_red.send(message).await;
    }

    Ok(Json(json!({
        "message": "Pipeline orchestrated successfully",
        "pipeline_id": req.pipeline_id,
        "nodes": run_stats.nodes_count,
        "edges": run_stats.edges_count,
    })))
}

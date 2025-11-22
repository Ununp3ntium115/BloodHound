use anyhow::Result;
use axum::{
    routing::{get, post},
    Router,
};
use std::net::SocketAddr;
use tokio::signal;

mod api;
mod datapipe;
mod monitoring;
mod orchestrator;

use api::handlers;
use api::state::AppState;
use pyro_core::config::Config;

#[tokio::main]
async fn main() -> Result<()> {
    // Initialize Fire Marshal branding
    println!("🚒 Fire Marshal - Data Flow Orchestration");
    println!("   Watching over autonomous data pipelines\n");

    // Load configuration
    let config = Config::load()?;

    // Initialize application state
    let state = AppState::new(config).await?;

    // Build router
    let app = Router::new()
        .route("/", get(handlers::root))
        .route("/health", get(handlers::health))
        .route("/api/monitor", get(handlers::get_monitoring))
        .route("/api/orchestrate", post(handlers::orchestrate))
        .with_state(state.clone());

    let _pipeline_worker = datapipe::spawn_pipeline_worker(state.clone());

    // Start server
    let addr = SocketAddr::from(([127, 0, 0, 1], 3001));
    println!("🚒 Fire Marshal is on patrol at {}", addr);

    let listener = tokio::net::TcpListener::bind(&addr).await?;
    axum::serve(listener, app)
        .with_graceful_shutdown(shutdown_signal())
        .await?;

    Ok(())
}

async fn shutdown_signal() {
    let ctrl_c = async {
        signal::ctrl_c()
            .await
            .expect("Failed to install Ctrl+C handler");
    };

    #[cfg(unix)]
    let terminate = async {
        signal::unix::signal(signal::unix::SignalKind::terminate())
            .expect("Failed to install signal handler")
            .recv()
            .await;
    };

    #[cfg(not(unix))]
    let terminate = std::future::pending::<()>();

    tokio::select! {
        _ = ctrl_c => {},
        _ = terminate => {},
    }

    println!("🚒 Fire Marshal signing off - systems secure");
}

use anyhow::{Context, Result};
use axum::{
    middleware::from_fn,
    routing::{get, post},
    Router,
};
use std::net::SocketAddr;
use tokio::signal;

mod api;
mod auth;
mod bootstrap;
mod branding;
mod config;
mod data_extractor;
mod database;

use api::{handlers, middleware, state::AppState};
use bootstrap::bloodsniffer_ensure_directories;
use config::Config;

#[tokio::main]
async fn main() -> Result<()> {
    // Initialize branding
    branding::print_banner();

    // Load configuration
    let config = Config::load()?;

    // Ensure directories exist
    bloodsniffer_ensure_directories(&config)?;

    // Initialize application state
    let state = AppState::new(config.clone()).await?;

    // Run database migrations
    bootstrap::bloodsniffer_migrate_db(&state).await?;

    // Build router
    let public_routes = Router::new()
        .route("/", get(handlers::root))
        .route("/health", get(handlers::health))
        .route("/api/login", post(handlers::api_login_with_secret));

    let protected_routes = Router::new()
        .route("/api/logout", post(handlers::api_logout))
        .route("/api/validate", get(handlers::api_validate_session))
        .route("/api/cryptex", post(handlers::create_cryptex))
        .route("/api/cryptex/:id", get(handlers::get_cryptex))
        .route("/api/extract", post(handlers::extract_data))
        .route("/api/pipeline", post(handlers::create_pipeline))
        .layer(from_fn(middleware::require_auth_middleware))
        .layer(from_fn(middleware::auth_middleware));

    let app = public_routes.merge(protected_routes).with_state(state);

    // Start server
    let addr_str = format!("{}:{}", config.server.host, config.server.port);
    let addr: SocketAddr = addr_str
        .parse()
        .with_context(|| format!("Invalid server address '{}'", addr_str))?;
    println!("🩸 BloodSniffer is active at {}", addr);

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

    println!("🩸 BloodSniffer shutting down gracefully");
}

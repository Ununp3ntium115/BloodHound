use anyhow::Result;
use pyro_detector::config::DetectorConfig;
use pyro_detector::mcp_server::PyroDetectorServer;

#[tokio::main]
async fn main() -> Result<()> {
    println!("🔥 PYRO Detector - MCP Server for PYRO Platform Ignition");
    println!("   Detonator Service - CDIF Compliant");
    println!("   Connecting to PYRO Platform Ignition...\n");

    // Load configuration
    let config = DetectorConfig::load()?;

    println!("Configuration loaded:");
    println!("  API URL: {}", config.pyro_api_url);
    println!("  CDIF Compliance: {}", config.cdif_compliance);
    println!("  Fire Marshal Terminology: {}\n", config.fire_marshal_terminology);

    // Create and run server
    let mut server = PyroDetectorServer::new(config)?;
    server.run().await?;

    Ok(())
}


use anyhow::Result;
use node_red_bridge::NodeRedBridge;
use std::path::PathBuf;
use std::sync::Arc;
use tokio::sync::RwLock;

use crate::config::Config;

/// Application state shared across all handlers
#[derive(Clone)]
pub struct AppState {
    pub config: Config,
    pub cryptex_root: PathBuf,
    pub node_red: Arc<RwLock<NodeRedBridge>>,
}

impl AppState {
    /// Create new application state
    pub async fn new(config: Config) -> Result<Self> {
        // Initialize Cryptex root directory
        let cryptex_root = config.database.path.join("cryptex");
        std::fs::create_dir_all(&cryptex_root)?;

        // Initialize Node-RED bridge
        let mut bridge = NodeRedBridge::new();

        if let Some(mqtt_broker) = &config.node_red.mqtt_broker {
            bridge = bridge.with_mqtt(mqtt_broker.clone());
        }

        if let Some(http_endpoint) = &config.node_red.http_endpoint {
            bridge = bridge.with_http(http_endpoint.clone());
        }

        let node_red = Arc::new(RwLock::new(bridge));

        Ok(Self {
            config,
            cryptex_root,
            node_red,
        })
    }
}

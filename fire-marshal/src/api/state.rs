use anyhow::Result;
use node_red_bridge::NodeRedBridge;
use redb::Database;
use std::path::PathBuf;
use std::sync::Arc;
use std::time::Duration;
use tokio::sync::RwLock;

use crate::monitoring::Monitor;
use crate::orchestrator::Orchestrator;
use pyro_core::config::Config;

/// Application state for Fire Marshal
#[derive(Clone)]
pub struct AppState {
    pub orchestrator: Arc<RwLock<Orchestrator>>,
    pub monitor: Arc<RwLock<Monitor>>,
    pub node_red: Arc<RwLock<NodeRedBridge>>,
    pub db: Arc<Database>,
    pub pipeline_dir: PathBuf,
    pub pipeline_interval: Duration,
}

impl AppState {
    /// Create new application state
    pub async fn new(config: Config) -> Result<Self> {
        // Initialize database inside the pipeline work directory
        std::fs::create_dir_all(&config.pipeline.work_dir)?;
        let db_path = config.pipeline.work_dir.join("fire_marshal.redb");
        let db = Arc::new(Database::create(&db_path)?);

        // Initialize orchestrator
        let orchestrator = Arc::new(RwLock::new(Orchestrator::new()));

        // Initialize monitor
        let monitor = Arc::new(RwLock::new(Monitor::new()));

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
            orchestrator,
            monitor,
            node_red,
            db,
            pipeline_dir: config.pipeline.work_dir.clone(),
            pipeline_interval: Duration::from_secs(config.pipeline.datapipe_interval_secs.max(5)),
        })
    }
}

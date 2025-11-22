use anyhow::{Context, Result};
use serde::{Deserialize, Serialize};
use std::path::PathBuf;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Config {
    /// Server configuration
    pub server: ServerConfig,
    /// Database configuration
    pub database: DatabaseConfig,
    /// Node-RED configuration
    pub node_red: NodeRedConfig,
    /// Cryptex configuration
    pub cryptex: CryptexConfig,
    /// Graph configuration
    pub graph: GraphConfig,
    /// Pipeline configuration
    pub pipeline: PipelineConfig,
    /// Authentication configuration
    pub auth: AuthConfig,
    /// Default admin configuration
    pub default_admin: DefaultAdminConfig,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ServerConfig {
    pub host: String,
    pub port: u16,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DatabaseConfig {
    pub path: PathBuf,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct NodeRedConfig {
    pub mqtt_broker: Option<String>,
    pub http_endpoint: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CryptexConfig {
    pub default_theme: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct GraphConfig {
    pub uri: String,
    pub username: String,
    pub password: String,
    pub driver: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PipelineConfig {
    pub work_dir: PathBuf,
    pub datapipe_interval_secs: u64,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AuthConfig {
    pub jwt_secret: String,
    pub session_duration_hours: i64,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DefaultAdminConfig {
    pub principal_name: String,
    pub password: String,
    pub email_address: String,
    pub first_name: String,
    pub last_name: String,
    pub expire_now: bool,
}

impl Config {
    /// Load configuration from file or use defaults
    pub fn load() -> Result<Self> {
        // Try to load from file
        if let Ok(config_str) = std::fs::read_to_string("bloodsniffer.toml") {
            return toml::from_str(&config_str).context("Failed to parse configuration file");
        }

        // Use defaults
        Ok(Self::default())
    }

    /// Save configuration to file
    pub fn save(&self) -> Result<()> {
        let config_str =
            toml::to_string_pretty(self).context("Failed to serialize configuration")?;
        std::fs::write("bloodsniffer.toml", config_str)
            .context("Failed to write configuration file")?;
        Ok(())
    }
}

impl Default for Config {
    fn default() -> Self {
        Self {
            server: ServerConfig {
                host: "127.0.0.1".to_string(),
                port: 3000,
            },
            database: DatabaseConfig {
                path: PathBuf::from("./data/bloodsniffer.redb"),
            },
            node_red: NodeRedConfig {
                mqtt_broker: Some("tcp://localhost:1883".to_string()),
                http_endpoint: Some("http://localhost:1880/bloodsniffer".to_string()),
            },
            cryptex: CryptexConfig {
                default_theme: "anarchist".to_string(),
            },
            graph: GraphConfig {
                uri: "neo4j://localhost:7687".to_string(),
                username: "neo4j".to_string(),
                password: "ChangeMe123!".to_string(),
                driver: "neo4j".to_string(),
            },
            pipeline: PipelineConfig {
                work_dir: PathBuf::from("./work/pipelines"),
                datapipe_interval_secs: 60,
            },
            auth: AuthConfig {
                jwt_secret: std::env::var("BLOOD_SNIFFER_JWT_SECRET")
                    .or_else(|_| std::env::var("PYRO_JWT_SECRET"))
                    .unwrap_or_else(|_| "change-me-in-prod".to_string()),
                session_duration_hours: 24,
            },
            default_admin: DefaultAdminConfig {
                principal_name: "admin".to_string(),
                password: "ChangeMe123!".to_string(),
                email_address: "admin@bloodsniffer.local".to_string(),
                first_name: "Admin".to_string(),
                last_name: "User".to_string(),
                expire_now: false,
            },
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_default_config() {
        let config = Config::default();
        assert_eq!(config.server.port, 3000);
        assert_eq!(config.cryptex.default_theme, "anarchist");
        assert_eq!(config.auth.session_duration_hours, 24);
        assert!(!config.auth.jwt_secret.is_empty());
        assert_eq!(config.graph.driver, "neo4j");
        assert_eq!(config.pipeline.datapipe_interval_secs, 60);
        assert!(config
            .pipeline
            .work_dir
            .to_string_lossy()
            .ends_with("work/pipelines"));
    }
}

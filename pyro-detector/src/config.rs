use anyhow::{Context, Result};
use serde::{Deserialize, Serialize};
use std::path::PathBuf;

/// Configuration for PYRO Detector MCP Server
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DetectorConfig {
    /// PYRO Platform Ignition API base URL
    pub pyro_api_url: String,
    
    /// API authentication token (JWT)
    pub api_token: Option<String>,
    
    /// Username for authentication (if token not provided)
    pub username: Option<String>,
    
    /// Password for authentication (if token not provided)
    pub password: Option<String>,
    
    /// Request timeout in seconds
    pub timeout_seconds: u64,
    
    /// Rate limit: requests per minute
    pub rate_limit_per_minute: u32,
    
    /// Enable CDIF compliance mode
    pub cdif_compliance: bool,
    
    /// Fire Marshal terminology enforcement
    pub fire_marshal_terminology: bool,
}

impl DetectorConfig {
    /// Load configuration from file or environment
    pub fn load() -> Result<Self> {
        // Try to load from config file
        let config_paths = vec![
            PathBuf::from("pyro-detector-config.json"),
            PathBuf::from(".pyro-detector-config.json"),
            PathBuf::from(std::env::var("HOME")?).join(".pyro-detector-config.json"),
        ];

        for path in config_paths {
            if path.exists() {
                let content = std::fs::read_to_string(&path)
                    .context(format!("Failed to read config from {:?}", path))?;
                let config: DetectorConfig = serde_json::from_str(&content)
                    .context("Failed to parse config file")?;
                return Ok(config);
            }
        }

        // Load from environment variables
        Ok(Self::from_env())
    }

    /// Create configuration from environment variables
    pub fn from_env() -> Self {
        Self {
            pyro_api_url: std::env::var("PYRO_API_URL")
                .unwrap_or_else(|_| "http://localhost:3001".to_string()),
            api_token: std::env::var("PYRO_API_TOKEN").ok(),
            username: std::env::var("PYRO_USERNAME").ok(),
            password: std::env::var("PYRO_PASSWORD").ok(),
            timeout_seconds: std::env::var("PYRO_TIMEOUT_SECONDS")
                .ok()
                .and_then(|s| s.parse().ok())
                .unwrap_or(30),
            rate_limit_per_minute: std::env::var("PYRO_RATE_LIMIT")
                .ok()
                .and_then(|s| s.parse().ok())
                .unwrap_or(100),
            cdif_compliance: std::env::var("PYRO_CDIF_COMPLIANCE")
                .map(|s| s == "true" || s == "1")
                .unwrap_or(true),
            fire_marshal_terminology: std::env::var("PYRO_FIRE_MARSHAL_TERMINOLOGY")
                .map(|s| s == "true" || s == "1")
                .unwrap_or(true),
        }
    }

    /// Get authentication token (login if needed)
    pub async fn get_token(&self) -> Result<String> {
        if let Some(token) = &self.api_token {
            return Ok(token.clone());
        }

        // Need to login
        if let (Some(username), Some(password)) = (&self.username, &self.password) {
            // Login will be handled by API client
            anyhow::bail!("Token required - set PYRO_API_TOKEN or provide username/password");
        }

        anyhow::bail!("No authentication credentials provided");
    }
}

impl Default for DetectorConfig {
    fn default() -> Self {
        Self {
            pyro_api_url: "http://localhost:3001".to_string(),
            api_token: None,
            username: None,
            password: None,
            timeout_seconds: 30,
            rate_limit_per_minute: 100,
            cdif_compliance: true,
            fire_marshal_terminology: true,
        }
    }
}


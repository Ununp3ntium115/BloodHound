use serde::{Deserialize, Serialize};
use std::time::Duration;

/// Health check information
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct HealthStatus {
    pub status: String,
    pub version: String,
    pub uptime_seconds: u64,
    pub last_api_check_timestamp: Option<u64>, // Unix timestamp
    pub api_healthy: bool,
    pub cdif_compliance: bool,
    pub fire_marshal_terminology: bool,
}

impl HealthStatus {
    /// Create new health status
    pub fn new() -> Self {
        Self {
            status: "healthy".to_string(),
            version: env!("CARGO_PKG_VERSION").to_string(),
            uptime_seconds: 0,
            last_api_check_timestamp: None,
            api_healthy: false,
            cdif_compliance: true,
            fire_marshal_terminology: true,
        }
    }

    /// Check if system is healthy
    pub fn is_healthy(&self) -> bool {
        self.status == "healthy" && self.api_healthy
    }

    /// Update API health status
    pub fn update_api_health(&mut self, healthy: bool) {
        self.api_healthy = healthy;
        self.last_api_check_timestamp = Some(
            std::time::SystemTime::now()
                .duration_since(std::time::UNIX_EPOCH)
                .unwrap_or_default()
                .as_secs()
        );
        
        if !healthy {
            self.status = "degraded".to_string();
        }
    }

    /// Update uptime
    pub fn update_uptime(&mut self, uptime: Duration) {
        self.uptime_seconds = uptime.as_secs();
    }
}

impl Default for HealthStatus {
    fn default() -> Self {
        Self::new()
    }
}

/// Health checker
pub struct HealthChecker {
    start_time: std::time::SystemTime,
    health: HealthStatus,
}

impl HealthChecker {
    /// Create new health checker
    pub fn new() -> Self {
        Self {
            start_time: std::time::SystemTime::now(),
            health: HealthStatus::new(),
        }
    }

    /// Get current health status
    pub fn get_health(&mut self) -> HealthStatus {
        let uptime = self.start_time
            .elapsed()
            .unwrap_or_default();
        self.health.update_uptime(uptime);
        self.health.clone()
    }

    /// Update API health
    pub fn update_api_health(&mut self, healthy: bool) {
        self.health.update_api_health(healthy);
    }

    /// Check if healthy
    pub fn is_healthy(&self) -> bool {
        self.health.is_healthy()
    }
}

impl Default for HealthChecker {
    fn default() -> Self {
        Self::new()
    }
}


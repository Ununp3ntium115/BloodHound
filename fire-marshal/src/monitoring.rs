use serde::{Deserialize, Serialize};

/// Monitoring statistics
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct MonitoringStats {
    pub active_pipelines: usize,
    pub data_processed: u64,
    pub errors: u64,
    pub last_update: i64,
}

/// Monitor for tracking system health
pub struct Monitor {
    stats: MonitoringStats,
}

impl Monitor {
    /// Create new monitor
    pub fn new() -> Self {
        Self {
            stats: MonitoringStats {
                active_pipelines: 0,
                data_processed: 0,
                errors: 0,
                last_update: chrono::Utc::now().timestamp(),
            },
        }
    }

    /// Get current statistics
    pub fn get_stats(&self) -> MonitoringStats {
        self.stats.clone()
    }

    /// Update statistics
    pub fn update_stats(&mut self, stats: MonitoringStats) {
        self.stats = stats;
        self.stats.last_update = chrono::Utc::now().timestamp();
    }

    /// Increment data processed
    pub fn increment_data(&mut self, amount: u64) {
        self.stats.data_processed += amount;
        self.stats.last_update = chrono::Utc::now().timestamp();
    }

    /// Increment error count
    pub fn increment_errors(&mut self) {
        self.stats.errors += 1;
        self.stats.last_update = chrono::Utc::now().timestamp();
    }

    /// Set number of active pipelines
    pub fn set_active_pipelines(&mut self, active: usize) {
        self.stats.active_pipelines = active;
        self.stats.last_update = chrono::Utc::now().timestamp();
    }
}

impl Default for Monitor {
    fn default() -> Self {
        Self::new()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_monitor() {
        let mut monitor = Monitor::new();
        monitor.increment_data(100);
        monitor.increment_errors();

        let stats = monitor.get_stats();
        assert_eq!(stats.data_processed, 100);
        assert_eq!(stats.errors, 1);
    }
}

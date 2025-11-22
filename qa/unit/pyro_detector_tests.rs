// Copyright 2025 Specter Ops, Inc.
//
// Licensed under the Apache License, Version 2.0
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// SPDX-License-Identifier: Apache-2.0

#[cfg(test)]
mod tests {
    use pyro_detector::config::DetectorConfig;
    use pyro_detector::logging::{LogLevel, Logger};
    use pyro_detector::types::*;
    use std::path::PathBuf;

    #[test]
    fn test_logger_creation() {
        let logger = Logger::new(LogLevel::Info, "./test_logs").unwrap();
        logger.info("TEST", "Test message");
        assert!(std::path::Path::new("./test_logs").exists());
    }

    #[test]
    fn test_log_levels() {
        let logger = Logger::new(LogLevel::Debug, "./test_logs").unwrap();
        logger.error("TEST", "Error");
        logger.warn("TEST", "Warning");
        logger.info("TEST", "Info");
        logger.debug("TEST", "Debug");
        logger.trace("TEST", "Trace");
    }

    #[test]
    fn test_config_loading() {
        // Test default config
        let config = DetectorConfig::default();
        assert!(!config.pyro_api_url.is_empty());
    }

    #[test]
    fn test_detonator_serialization() {
        let detonator = Detonator {
            id: "test-001".to_string(),
            name: "Test Detonator".to_string(),
            description: Some("Test description".to_string()),
            category: Some("test".to_string()),
            version: Some("1.0.0".to_string()),
        };
        
        let json = serde_json::to_string(&detonator).unwrap();
        assert!(json.contains("test-001"));
        assert!(json.contains("Test Detonator"));
    }

    #[test]
    fn test_detonator_execution_request() {
        let request = DetonatorExecutionRequest {
            detonator_id: "test-001".to_string(),
            case_id: Some("case-001".to_string()),
            parameters: Some(serde_json::json!({"key": "value"})),
        };
        
        let json = serde_json::to_string(&request).unwrap();
        assert!(json.contains("test-001"));
    }

    #[test]
    fn test_health_status() {
        use pyro_detector::health::HealthStatus;
        let health = HealthStatus::new();
        assert_eq!(health.status, "healthy");
    }
}


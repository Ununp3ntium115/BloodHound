use anyhow::Result;
use pyro_core::data_extractor::BloodHoundExtractor;
use serde::{Deserialize, Serialize};
use serde_json::Value;
use std::collections::HashMap;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Pipeline {
    pub id: String,
    pub source: String,
    pub destination: String,
    pub status: PipelineStatus,
    pub created_at: i64,
    pub last_run: Option<PipelineRunStats>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum PipelineStatus {
    Active,
    Paused,
    Stopped,
    Error(String),
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PipelineRunStats {
    pub nodes_count: usize,
    pub edges_count: usize,
    pub processed_at: i64,
}

/// Orchestrator for managing data pipelines
pub struct Orchestrator {
    pipelines: HashMap<String, Pipeline>,
}

impl Orchestrator {
    /// Create new orchestrator
    pub fn new() -> Self {
        Self {
            pipelines: HashMap::new(),
        }
    }

    /// Create a new pipeline and process payload
    pub fn create_pipeline(
        &mut self,
        id: &str,
        source: &str,
        destination: &str,
        payload: &Value,
    ) -> Result<PipelineRunStats> {
        let extracted = BloodHoundExtractor::extract_from_json(payload)?;
        let nodes_count = extracted.nodes.len();
        let edges_count = extracted.edges.len();
        let processed_at = chrono::Utc::now().timestamp();

        let run_stats = PipelineRunStats {
            nodes_count,
            edges_count,
            processed_at,
        };

        let pipeline = Pipeline {
            id: id.to_string(),
            source: source.to_string(),
            destination: destination.to_string(),
            status: PipelineStatus::Active,
            created_at: chrono::Utc::now().timestamp(),
            last_run: Some(run_stats.clone()),
        };

        self.pipelines.insert(id.to_string(), pipeline);
        Ok(run_stats)
    }

    /// Get pipeline by ID
    pub fn get_pipeline(&self, id: &str) -> Option<&Pipeline> {
        self.pipelines.get(id)
    }

    /// List all pipelines
    pub fn list_pipelines(&self) -> Vec<&Pipeline> {
        self.pipelines.values().collect()
    }

    /// Stop a pipeline
    pub fn stop_pipeline(&mut self, id: &str) -> Result<()> {
        if let Some(pipeline) = self.pipelines.get_mut(id) {
            pipeline.status = PipelineStatus::Stopped;
            Ok(())
        } else {
            anyhow::bail!("Pipeline not found: {}", id)
        }
    }

    /// Count active pipelines
    pub fn active_pipeline_count(&self) -> usize {
        self.pipelines
            .values()
            .filter(|p| matches!(p.status, PipelineStatus::Active))
            .count()
    }
}

impl Default for Orchestrator {
    fn default() -> Self {
        Self::new()
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use serde_json::json;

    #[test]
    fn test_orchestrator() {
        let mut orch = Orchestrator::new();
        let payload = json!({
            "data": [
                {
                    "ObjectIdentifier": "user1",
                    "Properties": {
                        "name": "testuser"
                    },
                    "Rels": []
                }
            ]
        });
        orch.create_pipeline("test1", "source1", "dest1", &payload)
            .unwrap();

        let pipeline = orch.get_pipeline("test1").unwrap();
        assert_eq!(pipeline.source, "source1");
        assert!(pipeline.last_run.is_some());
    }
}

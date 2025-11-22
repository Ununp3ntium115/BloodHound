use anyhow::{Context, Result};
use serde::{Deserialize, Serialize};
use serde_json::Value;
use std::fs;
use std::path::{Path, PathBuf};
use uuid::Uuid;

/// Definition for a queued data pipeline
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PipelineRecord {
    pub id: String,
    pub source: String,
    pub transformers: Vec<String>,
    pub destination: String,
    pub payload: Value,
    pub created_at: i64,
}

impl PipelineRecord {
    pub fn new(
        id: impl Into<String>,
        source: impl Into<String>,
        transformers: Vec<String>,
        destination: impl Into<String>,
        payload: Value,
    ) -> Self {
        Self {
            id: id.into(),
            source: source.into(),
            transformers,
            destination: destination.into(),
            payload,
            created_at: chrono::Utc::now().timestamp(),
        }
    }
}

/// Registry for storing queued pipelines on disk
pub struct PipelineRegistry {
    work_dir: PathBuf,
}

impl PipelineRegistry {
    pub fn new<P: AsRef<Path>>(work_dir: P) -> Self {
        Self {
            work_dir: work_dir.as_ref().to_path_buf(),
        }
    }

    /// Persist a pipeline record to disk
    pub fn persist(&self, record: &PipelineRecord) -> Result<PathBuf> {
        fs::create_dir_all(&self.work_dir)
            .with_context(|| format!("Failed to create {:?}", self.work_dir))?;

        let file_path = self
            .work_dir
            .join(format!("{}.json", record.id.replace(':', "_")));
        let serialized =
            serde_json::to_vec_pretty(record).context("Failed to serialize pipeline record")?;

        fs::write(&file_path, serialized)
            .with_context(|| format!("Failed to write pipeline file {:?}", file_path))?;

        Ok(file_path)
    }

    /// Generate a new pipeline identifier
    pub fn generate_id() -> String {
        Uuid::new_v4().to_string()
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use serde_json::json;
    use tempfile::TempDir;

    #[test]
    fn persist_pipeline_record() {
        let temp_dir = TempDir::new().unwrap();
        let registry = PipelineRegistry::new(temp_dir.path());
        let record = PipelineRecord::new(
            "test",
            "source",
            vec!["transform".into()],
            "dest",
            json!({"data": []}),
        );

        let path = registry.persist(&record).unwrap();
        assert!(path.exists());
    }
}



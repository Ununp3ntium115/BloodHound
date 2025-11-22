use anyhow::{Context, Result};
use chrono::Utc;
use serde::{Deserialize, Serialize};
use serde_json::Value;
use std::path::Path;
use uuid::Uuid;

/// Extract data from BloodHound JSON files
pub struct BloodHoundExtractor;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ExtractedData {
    pub nodes: Vec<Node>,
    pub edges: Vec<Edge>,
    pub metadata: DataMetadata,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Node {
    pub id: String,
    pub label: String,
    pub node_type: String,
    pub properties: Value,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Edge {
    pub source: String,
    pub target: String,
    pub edge_type: String,
    pub properties: Value,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DataMetadata {
    pub extracted_at: i64,
    pub source: String,
    pub total_nodes: usize,
    pub total_edges: usize,
}

impl BloodHoundExtractor {
    /// Extract data from BloodHound JSON file
    pub fn extract_from_file<P: AsRef<Path>>(path: P) -> Result<ExtractedData> {
        let content = std::fs::read_to_string(path).context("Failed to read file")?;

        let json: Value = serde_json::from_str(&content).context("Failed to parse JSON")?;

        Self::extract_from_json(&json)
    }

    /// Extract data from JSON value
    pub fn extract_from_json(json: &Value) -> Result<ExtractedData> {
        let mut nodes = Vec::new();
        let mut edges = Vec::new();

        // Extract nodes (computers, users, groups, etc.)
        if let Some(data_array) = json.get("data").and_then(|d| d.as_array()) {
            for item in data_array {
                if let Some(node_data) = item.get("Properties") {
                    let node_type = item
                        .get("ObjectIdentifier")
                        .and_then(|o| o.as_str())
                        .unwrap_or("unknown");

                    let node = Node {
                        id: Uuid::new_v4().to_string(),
                        label: node_type.to_string(),
                        node_type: node_type.to_string(),
                        properties: node_data.clone(),
                    };
                    nodes.push(node);
                }

                // Extract relationships/edges
                if let Some(rels) = item.get("Rels").and_then(|r| r.as_array()) {
                    for rel in rels {
                        let edge = Edge {
                            source: Uuid::new_v4().to_string(),
                            target: Uuid::new_v4().to_string(),
                            edge_type: rel
                                .get("RelType")
                                .and_then(|t| t.as_str())
                                .unwrap_or("unknown")
                                .to_string(),
                            properties: rel.clone(),
                        };
                        edges.push(edge);
                    }
                }
            }
        }

        let metadata = DataMetadata {
            extracted_at: Utc::now().timestamp(),
            source: "bloodhound".to_string(),
            total_nodes: nodes.len(),
            total_edges: edges.len(),
        };

        Ok(ExtractedData {
            nodes,
            edges,
            metadata,
        })
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use serde_json::json;

    #[test]
    fn test_extract_from_json() {
        let json = json!({
            "data": [
                {
                    "ObjectIdentifier": "user1",
                    "Properties": {
                        "name": "testuser"
                    },
                    "Rels": [
                        {
                            "RelType": "MemberOf",
                            "TargetObjectIdentifier": "group1"
                        }
                    ]
                }
            ]
        });

        let result = BloodHoundExtractor::extract_from_json(&json).unwrap();
        assert!(result.nodes.len() > 0);
        assert_eq!(result.metadata.source, "bloodhound");
    }
}

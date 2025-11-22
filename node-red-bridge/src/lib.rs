use anyhow::{Context, Result};
use serde::{Deserialize, Serialize};
use serde_json::Value;
use std::collections::HashMap;
use tokio::sync::mpsc;

mod http_bridge;
mod mqtt_bridge;

pub use http_bridge::HttpBridge;
pub use mqtt_bridge::MqttBridge;

/// Node-RED message format
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct NodeRedMessage {
    /// Message ID
    pub msg_id: String,
    /// Topic for routing
    pub topic: String,
    /// Payload data
    pub payload: Value,
    /// Metadata
    #[serde(flatten)]
    pub metadata: HashMap<String, Value>,
}

impl NodeRedMessage {
    /// Create a new message
    pub fn new(topic: String, payload: Value) -> Self {
        Self {
            msg_id: uuid::Uuid::new_v4().to_string(),
            topic,
            payload,
            metadata: HashMap::new(),
        }
    }

    /// Add metadata field
    pub fn with_metadata(mut self, key: String, value: Value) -> Self {
        self.metadata.insert(key, value);
        self
    }

    /// Serialize to JSON
    pub fn to_json(&self) -> Result<String> {
        serde_json::to_string(self).context("Failed to serialize message")
    }

    /// Deserialize from JSON
    pub fn from_json(json: &str) -> Result<Self> {
        serde_json::from_str(json).context("Failed to deserialize message")
    }
}

/// Node-RED bridge for data flow integration
pub struct NodeRedBridge {
    /// MQTT bridge (optional)
    mqtt: Option<MqttBridge>,
    /// HTTP bridge (optional)
    http: Option<HttpBridge>,
    /// Message sender channel
    tx: mpsc::UnboundedSender<NodeRedMessage>,
    /// Message receiver channel
    rx: Option<mpsc::UnboundedReceiver<NodeRedMessage>>,
}

impl NodeRedBridge {
    /// Create a new bridge
    pub fn new() -> Self {
        let (tx, rx) = mpsc::unbounded_channel();
        Self {
            mqtt: None,
            http: None,
            tx,
            rx: Some(rx),
        }
    }

    /// Enable MQTT bridge
    pub fn with_mqtt(mut self, broker_url: String) -> Self {
        self.mqtt = Some(MqttBridge::new(broker_url));
        self
    }

    /// Enable HTTP bridge
    pub fn with_http(mut self, endpoint_url: String) -> Self {
        self.http = Some(HttpBridge::new(endpoint_url));
        self
    }

    /// Send message to Node-RED
    pub async fn send(&self, message: NodeRedMessage) -> Result<()> {
        // Send via MQTT if available
        if let Some(mqtt) = &self.mqtt {
            mqtt.publish(&message).await?;
        }

        // Send via HTTP if available
        if let Some(http) = &self.http {
            http.post(&message).await?;
        }

        Ok(())
    }

    /// Receive messages (async stream)
    pub async fn receive(&mut self) -> Option<NodeRedMessage> {
        if let Some(rx) = &mut self.rx {
            rx.recv().await
        } else {
            None
        }
    }

    /// Get message sender
    pub fn sender(&self) -> mpsc::UnboundedSender<NodeRedMessage> {
        self.tx.clone()
    }
}

impl Default for NodeRedBridge {
    fn default() -> Self {
        Self::new()
    }
}

/// Builder for data pipelines
pub struct PipelineBuilder {
    source: String,
    transformers: Vec<String>,
    destination: String,
}

impl PipelineBuilder {
    /// Create new pipeline builder
    pub fn new(source: String) -> Self {
        Self {
            source,
            transformers: Vec::new(),
            destination: String::new(),
        }
    }

    /// Add transformer
    pub fn transform(mut self, transformer: String) -> Self {
        self.transformers.push(transformer);
        self
    }

    /// Set destination
    pub fn to(mut self, destination: String) -> Self {
        self.destination = destination;
        self
    }

    /// Build pipeline configuration
    pub fn build(self) -> PipelineConfig {
        PipelineConfig {
            source: self.source,
            transformers: self.transformers,
            destination: self.destination,
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PipelineConfig {
    pub source: String,
    pub transformers: Vec<String>,
    pub destination: String,
}

#[cfg(test)]
mod tests {
    use super::*;
    use serde_json::json;

    #[test]
    fn test_message_creation() {
        let msg = NodeRedMessage::new("pyro/data".to_string(), json!({"fire": "burns"}));

        assert_eq!(msg.topic, "pyro/data");
        assert!(!msg.msg_id.is_empty());
    }

    #[test]
    fn test_message_serialization() {
        let msg = NodeRedMessage::new("test/topic".to_string(), json!({"data": 123}));

        let json_str = msg.to_json().unwrap();
        let parsed = NodeRedMessage::from_json(&json_str).unwrap();

        assert_eq!(parsed.topic, msg.topic);
    }

    #[test]
    fn test_pipeline_builder() {
        let pipeline = PipelineBuilder::new("cryptex".to_string())
            .transform("decrypt".to_string())
            .transform("parse".to_string())
            .to("node-red".to_string())
            .build();

        assert_eq!(pipeline.source, "cryptex");
        assert_eq!(pipeline.transformers.len(), 2);
        assert_eq!(pipeline.destination, "node-red");
    }
}

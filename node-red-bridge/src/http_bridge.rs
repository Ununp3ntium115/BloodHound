use crate::NodeRedMessage;
use anyhow::{Context, Result};
use reqwest::Client;

/// HTTP bridge for Node-RED integration
pub struct HttpBridge {
    endpoint_url: String,
    client: Client,
}

impl HttpBridge {
    /// Create new HTTP bridge
    pub fn new(endpoint_url: String) -> Self {
        Self {
            endpoint_url,
            client: Client::new(),
        }
    }

    /// POST message to Node-RED HTTP endpoint
    pub async fn post(&self, message: &NodeRedMessage) -> Result<()> {
        let response = self
            .client
            .post(&self.endpoint_url)
            .json(message)
            .send()
            .await
            .context("Failed to send HTTP request")?;

        if !response.status().is_success() {
            anyhow::bail!("HTTP request failed with status: {}", response.status());
        }

        Ok(())
    }

    /// GET from Node-RED HTTP endpoint
    pub async fn get(&self, path: &str) -> Result<NodeRedMessage> {
        let url = format!("{}/{}", self.endpoint_url, path);
        let response = self
            .client
            .get(&url)
            .send()
            .await
            .context("Failed to send HTTP request")?;

        if !response.status().is_success() {
            anyhow::bail!("HTTP request failed with status: {}", response.status());
        }

        let message: NodeRedMessage = response.json().await.context("Failed to parse response")?;

        Ok(message)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_http_bridge_creation() {
        let bridge = HttpBridge::new("http://localhost:1880/pyro".to_string());
        assert_eq!(bridge.endpoint_url, "http://localhost:1880/pyro");
    }
}

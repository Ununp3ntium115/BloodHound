use anyhow::Result;
use serde_json::Value;

/// Utility functions for PYRO Detector

/// Validate JSON-RPC 2.0 request format
pub fn validate_jsonrpc_request(request: &Value) -> Result<()> {
    // Check jsonrpc version
    let version = request.get("jsonrpc")
        .and_then(|v| v.as_str())
        .ok_or_else(|| anyhow::anyhow!("Missing or invalid 'jsonrpc' field"))?;
    
    if version != "2.0" {
        anyhow::bail!("Invalid JSON-RPC version: {}", version);
    }

    // Check method
    request.get("method")
        .and_then(|v| v.as_str())
        .ok_or_else(|| anyhow::anyhow!("Missing or invalid 'method' field"))?;

    // ID is optional but should be present for requests
    // (not required for notifications)

    Ok(())
}

/// Format error response
pub fn format_error(code: &str, message: &str, data: Option<Value>) -> Value {
    let mut error = serde_json::json!({
        "code": code,
        "message": message
    });

    if let Some(data) = data {
        error["data"] = data;
    }

    serde_json::json!({
        "jsonrpc": "2.0",
        "error": error
    })
}

/// Format success response
pub fn format_success(id: Option<&Value>, result: Value) -> Value {
    let mut response = serde_json::json!({
        "jsonrpc": "2.0",
        "result": result
    });

    if let Some(id) = id {
        response["id"] = id.clone();
    }

    response
}

/// Extract method name from request
pub fn extract_method(request: &Value) -> Option<&str> {
    request.get("method")?.as_str()
}

/// Extract params from request
pub fn extract_params(request: &Value) -> Value {
    request.get("params").cloned().unwrap_or_else(|| serde_json::json!({}))
}

/// Extract request ID
pub fn extract_id(request: &Value) -> Option<&Value> {
    request.get("id")
}

/// Check if request is a notification (no ID)
pub fn is_notification(request: &Value) -> bool {
    !request.get("id").is_some()
}

/// Sanitize error message for logging
pub fn sanitize_error_message(msg: &str) -> String {
    // Remove potential sensitive data
    msg.replace("password", "***")
       .replace("token", "***")
       .replace("secret", "***")
       .replace("api_key", "***")
}

/// Validate URL format
pub fn validate_url(url: &str) -> Result<()> {
    url::Url::parse(url)
        .map_err(|e| anyhow::anyhow!("Invalid URL: {}", e))?;
    Ok(())
}

/// Format duration for logging
pub fn format_duration_ms(duration: std::time::Duration) -> String {
    format!("{}ms", duration.as_millis())
}

/// Parse timeout from config
pub fn parse_timeout(timeout_seconds: u64) -> std::time::Duration {
    std::time::Duration::from_secs(timeout_seconds)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_validate_jsonrpc_request() {
        let valid = serde_json::json!({
            "jsonrpc": "2.0",
            "id": 1,
            "method": "test_method",
            "params": {}
        });
        assert!(validate_jsonrpc_request(&valid).is_ok());

        let invalid = serde_json::json!({
            "jsonrpc": "1.0",
            "method": "test_method"
        });
        assert!(validate_jsonrpc_request(&invalid).is_err());
    }

    #[test]
    fn test_sanitize_error_message() {
        let msg = "Authentication failed: password is incorrect";
        let sanitized = sanitize_error_message(msg);
        assert!(!sanitized.contains("password"));
        assert!(sanitized.contains("***"));
    }

    #[test]
    fn test_validate_url() {
        assert!(validate_url("http://localhost:3001").is_ok());
        assert!(validate_url("https://api.example.com").is_ok());
        assert!(validate_url("not-a-url").is_err());
    }
}


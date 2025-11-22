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
mod integration_tests {
    use std::process::{Command, Stdio};
    use std::io::Write;
    use serde_json::json;

    fn call_mcp_server(method: &str, params: serde_json::Value) -> Result<serde_json::Value, Box<dyn std::error::Error>> {
        let binary = std::env::var("MCP_BINARY").unwrap_or_else(|_| "./target/release/pyro-detector".to_string());
        
        let request = json!({
            "jsonrpc": "2.0",
            "id": 1,
            "method": method,
            "params": params
        });

        let mut child = Command::new(&binary)
            .stdin(Stdio::piped())
            .stdout(Stdio::piped())
            .stderr(Stdio::piped())
            .spawn()?;

        if let Some(mut stdin) = child.stdin.take() {
            writeln!(stdin, "{}", serde_json::to_string(&request)?)?;
        }

        let output = child.wait_with_output()?;
        let response: serde_json::Value = serde_json::from_slice(&output.stdout)?;
        Ok(response)
    }

    #[test]
    #[ignore] // Requires MCP server binary
    fn test_mcp_health_check() {
        let response = call_mcp_server("pyro_health", json!({})).unwrap();
        assert!(response.get("result").is_some());
    }

    #[test]
    #[ignore] // Requires MCP server binary
    fn test_mcp_list_detonators() {
        let response = call_mcp_server("pyro_list_detonators", json!({})).unwrap();
        assert!(response.get("result").is_some());
    }

    #[test]
    #[ignore] // Requires MCP server binary
    fn test_mcp_error_handling() {
        let response = call_mcp_server("invalid_method", json!({})).unwrap();
        assert!(response.get("error").is_some());
    }
}


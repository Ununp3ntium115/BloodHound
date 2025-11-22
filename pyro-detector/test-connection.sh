#!/bin/bash
# Test script for PYRO Detector MCP Server

set -e

echo "🔥 PYRO Detector Connection Test"
echo "================================"
echo ""

# Check if binary exists
if [ ! -f "target/release/pyro-detector" ]; then
    echo "❌ Binary not found. Building..."
    cargo build --release
fi

echo "✅ Binary found"
echo ""

# Test 1: Health check
echo "Test 1: Health Check"
echo "--------------------"
echo '{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "pyro_health",
  "params": {}
}' | ./target/release/pyro-detector | jq .

echo ""
echo ""

# Test 2: Authenticate
echo "Test 2: Authentication"
echo "---------------------"
echo '{
  "jsonrpc": "2.0",
  "id": 2,
  "method": "pyro_authenticate",
  "params": {}
}' | ./target/release/pyro-detector | jq .

echo ""
echo ""

# Test 3: List detonators
echo "Test 3: List Detonators"
echo "----------------------"
echo '{
  "jsonrpc": "2.0",
  "id": 3,
  "method": "pyro_list_detonators",
  "params": {
    "investigation_type": "ransomware"
  }
}' | ./target/release/pyro-detector | jq .

echo ""
echo ""

# Test 4: List agents
echo "Test 4: List Agents"
echo "------------------"
echo '{
  "jsonrpc": "2.0",
  "id": 4,
  "method": "pyro_list_agents",
  "params": {}
}' | ./target/release/pyro-detector | jq .

echo ""
echo "✅ All tests completed!"
echo ""

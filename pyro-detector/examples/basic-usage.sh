#!/bin/bash
# Basic usage examples for PYRO Detector

echo "🔥 PYRO Detector - Basic Usage Examples"
echo "======================================="
echo ""

DETECTOR="./target/release/pyro-detector"

# Example 1: Health Check
echo "Example 1: Health Check"
echo "----------------------"
echo '{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "pyro_health",
  "params": {}
}' | $DETECTOR | jq '.result.health'
echo ""

# Example 2: List Detonators
echo "Example 2: List Ransomware Detonators"
echo "-------------------------------------"
echo '{
  "jsonrpc": "2.0",
  "id": 2,
  "method": "pyro_list_detonators",
  "params": {
    "investigation_type": "ransomware",
    "platform": "windows"
  }
}' | $DETECTOR | jq '.result.detonators[0:3]'  # Show first 3
echo ""

# Example 3: Create Case
echo "Example 3: Create Investigation Case"
echo "------------------------------------"
echo '{
  "jsonrpc": "2.0",
  "id": 3,
  "method": "pyro_create_case",
  "params": {
    "case_id": "CASE-FM-2025-001",
    "case_name": "Ransomware Investigation - Example",
    "investigation_type": "ransomware",
    "priority": "P0",
    "status": "active"
  }
}' | $DETECTOR | jq '.result.case'
echo ""

# Example 4: List Agents
echo "Example 4: List All Agents"
echo "-------------------------"
echo '{
  "jsonrpc": "2.0",
  "id": 4,
  "method": "pyro_list_agents",
  "params": {}
}' | $DETECTOR | jq '.result.agents[0:3]'  # Show first 3
echo ""

# Example 5: Execute PQL Query
echo "Example 5: Execute PQL Query"
echo "---------------------------"
echo '{
  "jsonrpc": "2.0",
  "id": 5,
  "method": "pyro_execute_pql",
  "params": {
    "query": "SELECT process_name, pid FROM processes WHERE suspicious = true LIMIT 10",
    "timeout_seconds": 60
  }
}' | $DETECTOR | jq '.result.query'
echo ""

echo "✅ Examples completed!"
echo ""


#!/bin/bash
# Complete investigation workflow example

echo "🔥 PYRO Detector - Complete Investigation Workflow"
echo "=================================================="
echo ""

DETECTOR="./target/release/pyro-detector"
CASE_ID="CASE-FM-$(date +%Y%m%d)-001"

# Step 1: Create Investigation Case
echo "Step 1: Creating Investigation Case"
echo "------------------------------------"
CASE_RESPONSE=$(echo "{
  \"jsonrpc\": \"2.0\",
  \"id\": 1,
  \"method\": \"pyro_create_case\",
  \"params\": {
    \"case_id\": \"$CASE_ID\",
    \"case_name\": \"Ransomware Investigation - $(date +%Y-%m-%d)\",
    \"investigation_type\": \"ransomware\",
    \"priority\": \"P0\",
    \"status\": \"active\"
  }
}" | $DETECTOR)

echo "$CASE_RESPONSE" | jq '.result.case'
echo ""

# Step 2: List Available Detonators
echo "Step 2: Listing Available Detonators"
echo "-------------------------------------"
DETONATORS=$(echo "{
  \"jsonrpc\": \"2.0\",
  \"id\": 2,
  \"method\": \"pyro_list_detonators\",
  \"params\": {
    \"investigation_type\": \"ransomware\",
    \"platform\": \"windows\"
  }
}" | $DETECTOR)

DETONATOR_ID=$(echo "$DETONATORS" | jq -r '.result.detonators[0].id // "DET-RAN-001"')
echo "Selected detonator: $DETONATOR_ID"
echo ""

# Step 3: Execute Detonator
echo "Step 3: Executing Detonator"
echo "---------------------------"
EXECUTION=$(echo "{
  \"jsonrpc\": \"2.0\",
  \"id\": 3,
  \"method\": \"pyro_execute_detonator\",
  \"params\": {
    \"detonator_id\": \"$DETONATOR_ID\",
    \"case_id\": \"$CASE_ID\",
    \"investigation_type\": \"ransomware\",
    \"parameters\": {
      \"scan_depth\": \"deep\",
      \"include_memory\": true
    },
    \"evidence_chain\": {
      \"case_id\": \"$CASE_ID\",
      \"quantum_verification\": true
    }
  }
}" | $DETECTOR)

echo "$EXECUTION" | jq '.result.execution.execution_id'
echo "$EXECUTION" | jq '.result.execution.detonator.name'
echo ""

# Step 4: List Agents for Follow-up
echo "Step 4: Listing Agents for Follow-up Queries"
echo "---------------------------------------------"
AGENTS=$(echo "{
  \"jsonrpc\": \"2.0\",
  \"id\": 4,
  \"method\": \"pyro_list_agents\",
  \"params\": {}
}" | $DETECTOR)

AGENT_COUNT=$(echo "$AGENTS" | jq '.result.count')
echo "Available agents: $AGENT_COUNT"
echo ""

# Step 5: Execute PQL Query on Agents
echo "Step 5: Executing PQL Query"
echo "---------------------------"
PQL=$(echo "{
  \"jsonrpc\": \"2.0\",
  \"id\": 5,
  \"method\": \"pyro_execute_pql\",
  \"params\": {
    \"query\": \"SELECT * FROM processes WHERE suspicious = true AND investigation_type = 'ransomware'\",
    \"timeout_seconds\": 300,
    \"max_results\": 1000
  }
}" | $DETECTOR)

echo "$PQL" | jq '.result.query.status'
echo ""

echo "✅ Investigation workflow completed!"
echo "Case ID: $CASE_ID"
echo ""


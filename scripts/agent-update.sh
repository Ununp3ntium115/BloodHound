#!/bin/bash
# Update task status

if [ -z "$3" ]; then
    echo "Usage: $0 <module> <task_id> <status>"
    echo "Example: $0 auth auth_Login Completed"
    echo ""
    echo "Status values: NotStarted, InProgress, Completed, Blocked"
    exit 1
fi

MODULE=$1
TASK_ID=$2
STATUS=$3

echo "🔥 Updating task status..."
echo "   Module: $MODULE"
echo "   Task: $TASK_ID"
echo "   Status: $STATUS"
echo ""

cargo run --bin mcp-translator <<EOF
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "update_task_status",
  "params": {
    "module": "$MODULE",
    "task_id": "$TASK_ID",
    "status": "$STATUS"
  }
}
EOF

echo ""
echo "✅ Task status updated!"


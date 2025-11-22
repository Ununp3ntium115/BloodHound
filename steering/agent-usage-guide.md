# Agent Usage Guide - Pyro Implementation Tracking

🔥 **Using Agents to Track and Manage Implementation** 🔥

The MCP Translator now includes an **agent system** that automatically creates implementation agents for each module, tracks progress, and provides implementation roadmaps.

---

## Quick Start

### 1. Create Agents from Gap Analysis

First, create agents based on the current gap analysis:

```bash
cargo run --bin mcp-translator <<EOF
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "create_agents",
  "params": {
    "go_source_path": "./cmd/api/src",
    "rust_source_path": "./pyro-core/src"
  }
}
EOF
```

**Response**:
```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": {
    "success": true,
    "agents_created": 11,
    "agents": [
      {
        "name": "auth_agent",
        "module": "auth",
        "status": "Pending",
        "priority": "Critical",
        "progress": 0.0,
        "total_tasks": 137
      },
      ...
    ]
  }
}
```

---

### 2. Get Implementation Roadmap

View the prioritized implementation roadmap:

```bash
cargo run --bin mcp-translator <<EOF
{
  "jsonrpc": "2.0",
  "id": 2,
  "method": "get_roadmap",
  "params": {}
}
EOF
```

**Response**:
```json
{
  "jsonrpc": "2.0",
  "id": 2,
  "result": {
    "critical": [
      {
        "name": "auth_agent",
        "module": "auth",
        "status": "Pending",
        "progress": 0.0,
        "total_tasks": 137,
        "completed_tasks": 0
      },
      ...
    ],
    "high": [...],
    "medium": [...],
    "low": [...]
  }
}
```

---

### 3. Get Implementation Plan for a Module

Get a detailed implementation plan for a specific module:

```bash
cargo run --bin mcp-translator <<EOF
{
  "jsonrpc": "2.0",
  "id": 3,
  "method": "get_implementation_plan",
  "params": {
    "module": "auth",
    "go_source_path": "./cmd/api/src",
    "rust_source_path": "./pyro-core/src"
  }
}
EOF
```

**Response**:
```json
{
  "jsonrpc": "2.0",
  "id": 3,
  "result": {
    "module": "auth",
    "total_functions": 137,
    "missing_functions": 137,
    "coverage": 0.0,
    "phases": [
      {
        "phase": 1,
        "name": "Core Functions",
        "description": "Implement essential functions for module operation",
        "functions": ["Login", "Logout", "ValidateSession", ...]
      },
      ...
    ],
    "file_groups": {
      "./cmd/api/src/auth/totp.go": 15,
      "./cmd/api/src/auth/saml.go": 20,
      ...
    }
  }
}
```

---

### 4. Get Agent Details

View details for a specific agent:

```bash
cargo run --bin mcp-translator <<EOF
{
  "jsonrpc": "2.0",
  "id": 4,
  "method": "get_agents",
  "params": {
    "module": "auth"
  }
}
EOF
```

**Response**:
```json
{
  "jsonrpc": "2.0",
  "id": 4,
  "result": {
    "agents": [
      {
        "name": "auth_agent",
        "module": "auth",
        "status": "InProgress",
        "priority": "Critical",
        "progress": 25.5,
        "tasks": [
          {
            "id": "auth_Login",
            "description": "Implement Login",
            "status": "Completed",
            "functions": ["Login"]
          },
          {
            "id": "auth_Logout",
            "description": "Implement Logout",
            "status": "Completed",
            "functions": ["Logout"]
          },
          {
            "id": "auth_TOTP",
            "description": "Implement TOTP",
            "status": "InProgress",
            "functions": ["GenerateTOTP", "ValidateTOTP"]
          },
          ...
        ]
      }
    ]
  }
}
```

---

### 5. Update Task Status

Mark tasks as completed or update their status:

```bash
cargo run --bin mcp-translator <<EOF
{
  "jsonrpc": "2.0",
  "id": 5,
  "method": "update_task_status",
  "params": {
    "module": "auth",
    "task_id": "auth_TOTP",
    "status": "Completed"
  }
}
EOF
```

**Response**:
```json
{
  "jsonrpc": "2.0",
  "id": 5,
  "result": {
    "success": true,
    "agent": {
      "name": "auth_agent",
      "module": "auth",
      "status": "InProgress",
      "progress": 30.0
    }
  }
}
```

---

## Agent Status Values

- **Pending**: Agent created but no work started
- **InProgress**: Agent has tasks in progress
- **Blocked**: Agent is blocked by dependencies
- **Completed**: All tasks completed
- **Review**: Agent work needs review

## Task Status Values

- **NotStarted**: Task not yet started
- **InProgress**: Task currently being worked on
- **Completed**: Task finished
- **Blocked**: Task blocked by dependencies

## Priority Levels

- **Critical**: Must be completed first (auth, api, bootstrap, database)
- **High**: Important for core functionality (graphify, datapipe, upload)
- **Medium**: Important but not blocking (queries, analysis)
- **Low**: Nice to have (utils, helpers)

---

## Workflow Example

### Starting a New Module Implementation

1. **Create agents** (if not already done):
   ```bash
   cargo run --bin mcp-translator <<EOF
   {
     "jsonrpc": "2.0",
     "id": 1,
     "method": "create_agents",
     "params": {
       "go_source_path": "./cmd/api/src",
       "rust_source_path": "./pyro-core/src"
     }
   }
   EOF
   ```

2. **Get implementation plan**:
   ```bash
   cargo run --bin mcp-translator <<EOF
   {
     "jsonrpc": "2.0",
     "id": 2,
     "method": "get_implementation_plan",
     "params": {
       "module": "auth",
       "go_source_path": "./cmd/api/src",
       "rust_source_path": "./pyro-core/src"
     }
   }
   EOF
   ```

3. **Start implementing** Phase 1 functions

4. **Update task status** as you complete tasks:
   ```bash
   cargo run --bin mcp-translator <<EOF
   {
     "jsonrpc": "2.0",
     "id": 3,
     "method": "update_task_status",
     "params": {
       "module": "auth",
       "task_id": "auth_Login",
       "status": "Completed"
     }
   }
   EOF
   ```

5. **Check progress**:
   ```bash
   cargo run --bin mcp-translator <<EOF
   {
     "jsonrpc": "2.0",
     "id": 4,
     "method": "get_agents",
     "params": {
       "module": "auth"
     }
   }
   EOF
   ```

---

## Integration with Development Workflow

### Daily Standup

Use the roadmap to report progress:
```bash
cargo run --bin mcp-translator <<EOF
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "get_roadmap",
  "params": {}
}
EOF
```

### Sprint Planning

Use implementation plans to plan sprints:
```bash
# Get plan for each critical module
for module in auth api database; do
  cargo run --bin mcp-translator <<EOF
  {
    "jsonrpc": "2.0",
    "id": 1,
    "method": "get_implementation_plan",
    "params": {
      "module": "$module",
      "go_source_path": "./cmd/api/src",
      "rust_source_path": "./pyro-core/src"
    }
  }
  EOF
done
```

### Progress Tracking

Update task status as you complete work:
```bash
# After completing a function
cargo run --bin mcp-translator <<EOF
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "update_task_status",
  "params": {
    "module": "auth",
    "task_id": "auth_Login",
    "status": "Completed"
  }
}
EOF
```

---

## Tips and Best Practices

1. **Create agents once** at the start of a sprint
2. **Update task status regularly** as you complete work
3. **Use implementation plans** to guide your work
4. **Check roadmap** for prioritization
5. **Review agent progress** in daily standups

---

## Troubleshooting

### Agents not created

Make sure you call `create_agents` before using other agent methods.

### Agent not found

Check the module name matches exactly (case-sensitive).

### Task not found

Check the task_id matches the format: `{module}_{function_name}`

---

*For more details, see `steering/comprehensive-gap-analysis.md` and `steering/implementation-guide.md`*


# Agent Scripts - Quick Reference

🔥 **Helper Scripts for Agent System** 🔥

## Available Scripts

### 1. `agent-create.sh`
Create agents from gap analysis.

```bash
./scripts/agent-create.sh
```

**What it does**:
- Runs gap analysis
- Creates agents for each module
- Stores agent registry

---

### 2. `agent-roadmap.sh`
Get prioritized implementation roadmap.

```bash
./scripts/agent-roadmap.sh
```

**What it does**:
- Shows all agents organized by priority
- Displays progress for each agent
- Shows task counts

---

### 3. `agent-plan.sh <module>`
Get detailed implementation plan for a module.

```bash
./scripts/agent-plan.sh auth
./scripts/agent-plan.sh api
./scripts/agent-plan.sh database
```

**Available modules**:
- `auth` - Authentication module
- `api` - API endpoints
- `database` - Database models and operations
- `graphify` - Graph data ingestion
- `datapipe` - Data pipeline
- `upload` - File upload handling
- `queries` - Graph queries
- `analysis` - Analysis algorithms
- `config` - Configuration
- `bootstrap` - Bootstrap/initialization
- `utils` - Utilities

---

### 4. `agent-status.sh <module>`
Get current status for a specific agent.

```bash
./scripts/agent-status.sh auth
```

**What it shows**:
- Agent progress percentage
- Task list with status
- Functions to implement
- Dependencies

---

### 5. `agent-all-status.sh`
Get status for all agents.

```bash
./scripts/agent-all-status.sh
```

**What it shows**:
- All agents and their progress
- Overall project status
- Task completion counts

---

### 6. `agent-update.sh <module> <task_id> <status>`
Update task status.

```bash
./scripts/agent-update.sh auth auth_Login Completed
./scripts/agent-update.sh api api_GetUsers InProgress
```

**Status values**:
- `NotStarted` - Task not yet started
- `InProgress` - Currently working on it
- `Completed` - Task finished
- `Blocked` - Blocked by dependencies

---

### 7. `run-complete-audit.sh`
Run complete audit: gap analysis + agents + reports.

```bash
./scripts/run-complete-audit.sh
```

**What it does**:
1. Runs gap analysis
2. Creates agents
3. Generates roadmap
4. Collects status for all modules
5. Saves results to JSON files

**Output files**:
- `gap-analysis-raw.json` - Raw gap analysis results
- `agent-creation.json` - Agent creation results
- `roadmap.json` - Implementation roadmap
- `all-status.json` - Status for all agents

---

## Typical Workflow

### Starting a New Sprint

1. **Run complete audit**:
   ```bash
   ./scripts/run-complete-audit.sh
   ```

2. **Review roadmap**:
   ```bash
   ./scripts/agent-roadmap.sh
   ```

3. **Get plan for module**:
   ```bash
   ./scripts/agent-plan.sh auth
   ```

### During Implementation

1. **Check current status**:
   ```bash
   ./scripts/agent-status.sh auth
   ```

2. **Update task as you complete**:
   ```bash
   ./scripts/agent-update.sh auth auth_Login Completed
   ```

3. **Check progress**:
   ```bash
   ./scripts/agent-status.sh auth
   ```

### Daily Standup

1. **Get all status**:
   ```bash
   ./scripts/agent-all-status.sh
   ```

2. **Review roadmap**:
   ```bash
   ./scripts/agent-roadmap.sh
   ```

---

## Windows Usage

On Windows, you can use these scripts with:
- Git Bash
- WSL (Windows Subsystem for Linux)
- PowerShell (with modifications)

Or use the MCP server directly:
```powershell
cargo run --bin mcp-translator
# Then paste JSON-RPC requests
```

---

## Integration with CI/CD

You can integrate these scripts into CI/CD:

```yaml
# .github/workflows/progress.yml
- name: Run Audit
  run: ./scripts/run-complete-audit.sh
  
- name: Upload Reports
  uses: actions/upload-artifact@v3
  with:
    name: audit-reports
    path: |
      gap-analysis-raw.json
      roadmap.json
      all-status.json
```

---

## Troubleshooting

### Agents not created
Run `./scripts/agent-create.sh` first.

### Module not found
Check module name spelling (case-sensitive).

### Task not found
Check task_id format: `{module}_{function_name}`

---

*For more details, see `steering/agent-usage-guide.md`*


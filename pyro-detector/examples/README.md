# PYRO Detector Examples

🔥 **Usage Examples and Workflows** 🔥

## Examples

### Basic Usage (`basic-usage.sh`)

Demonstrates basic usage of all MCP methods:
- Health check
- List detonators
- Create case
- List agents
- Execute PQL query

**Usage**:
```bash
chmod +x examples/basic-usage.sh
./examples/basic-usage.sh
```

### Investigation Workflow (`investigation-workflow.sh`)

Complete end-to-end investigation workflow:
1. Create investigation case
2. List available detonators
3. Execute detonator
4. List agents for follow-up
5. Execute PQL query

**Usage**:
```bash
chmod +x examples/investigation-workflow.sh
./examples/investigation-workflow.sh
```

## Prerequisites

- PYRO Detector built (`cargo build --release`)
- PYRO Platform Ignition running
- Valid API credentials configured
- `jq` installed (for JSON formatting)

## Customization

Edit the scripts to:
- Change case IDs
- Modify detonator parameters
- Adjust query timeouts
- Add additional steps

---

🔥 **Start investigating!** 🔥


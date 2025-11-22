# Pyro Project: Complete A-to-B Workflow Guide

🔥 **From BloodHound Go Codebase to Pyro Rust System** 🔥

This document provides a complete guide on how to get from Point A (BloodHound Go codebase) to Point B (Pyro Rust system with Cryptex structure).

---

## Overview

**Point A**: BloodHound Go codebase (`cmd/api/src/`)
**Point B**: Pyro Rust system with:
- Rust-native implementation
- Cryptex hierarchical file structure
- Anarchist branding (Pyro/Fire Marshal)
- ReDB database
- Node-RED integration
- MCP translator for code conversion

---

## Phase 1: Analysis & Planning

### Step 1.1: Analyze Existing Codebase

**Tool**: MCP Translator - `analyze_codebase`

```bash
# Analyze the Go codebase structure
echo '{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "analyze_codebase",
  "params": {
    "directory_path": "./cmd/api/src",
    "language": "go"
  }
}' | cargo run --bin mcp-translator
```

**Output**: 
- Total files count
- Total functions count
- Function relationships
- Package structure

**Action**: Review analysis to understand codebase complexity

### Step 1.2: Extract Function Inventory

**Tool**: MCP Translator - `extract_functions`

```bash
# Extract functions from key files
for file in cmd/api/src/bootstrap/server.go cmd/api/src/api/auth.go; do
  echo "{
    \"jsonrpc\": \"2.0\",
    \"id\": 2,
    \"method\": \"extract_functions\",
    \"params\": {
      \"file_path\": \"$file\",
      \"language\": \"go\"
    }
  }" | cargo run --bin mcp-translator
done
```

**Output**: List of all functions with signatures

**Action**: Create function mapping document

---

## Phase 2: Translation to Cryptex

### Step 2.1: Translate Core Modules

**Tool**: MCP Translator - `translate_directory`

```bash
# Translate bootstrap module
echo '{
  "jsonrpc": "2.0",
  "id": 3,
  "method": "translate_directory",
  "params": {
    "directory_path": "./cmd/api/src/bootstrap",
    "language": "go",
    "cryptex_path": "./cryptex/pyro/bootstrap",
    "recursive": true
  }
}' | cargo run --bin mcp-translator
```

**Output**: Cryptex structure with anarchist naming

**Structure Created**:
```
cryptex/pyro/bootstrap/
  initialize_pyro_server/
    function.rs
    pseudocode.md
  initialize_pyro_server_flame_migrate_db/
    function.rs
    pseudocode.md
```

### Step 2.2: Translate API Handlers

```bash
# Translate API module
echo '{
  "jsonrpc": "2.0",
  "id": 4,
  "method": "translate_directory",
  "params": {
    "directory_path": "./cmd/api/src/api",
    "language": "go",
    "cryptex_path": "./cryptex/pyro/api",
    "recursive": true
  }
}' | cargo run --bin mcp-translator
```

### Step 2.3: Translate Database Layer

```bash
# Translate database module
echo '{
  "jsonrpc": "2.0",
  "id": 5,
  "method": "translate_directory",
  "params": {
    "directory_path": "./cmd/api/src/database",
    "language": "go",
    "cryptex_path": "./cryptex/pyro/database",
    "recursive": true
  }
}' | cargo run --bin mcp-translator
```

### Step 2.4: Translate Remaining Modules

Repeat for:
- `cmd/api/src/auth/` → `cryptex/pyro/auth/`
- `cmd/api/src/services/` → `cryptex/pyro/services/`
- `cmd/api/src/model/` → `cryptex/pyro/model/`
- `cmd/api/src/config/` → `cryptex/pyro/config/`

---

## Phase 3: Rust Implementation

### Step 3.1: Review Cryptex Structure

**Action**: Examine translated functions in Cryptex

```bash
# List all functions
find cryptex/pyro -name "function.rs" | head -20

# Review function pseudocode
cat cryptex/pyro/bootstrap/initialize_pyro_server/pseudocode.md
```

**Output**: Understanding of function structure and relationships

### Step 3.2: Implement Core Functions in Rust

**Pattern**: Use Cryptex dictionary for function names

**Example**: Converting `NewDaemonContext` Go function

**Go Original** (from `bootstrap/server.go`):
```go
func NewDaemonContext(parentCtx context.Context) context.Context {
    // ... implementation
}
```

**Rust Implementation** (using dictionary key `pyro_initialize`):
```rust
// In pyro-core/src/bootstrap.rs
pub fn pyro_initialize(parent_ctx: Context) -> Context {
    // Implementation based on pseudocode from Cryptex
}
```

**Location**: `pyro-core/src/bootstrap.rs`

### Step 3.3: Map Go Types to Rust Types

**Mapping Table**:

| Go Type | Rust Type | Notes |
|---------|-----------|-------|
| `context.Context` | `tokio::task::JoinHandle` | Async context |
| `error` | `anyhow::Result<T>` | Error handling |
| `*database.Database` | `Arc<Database>` | Shared reference |
| `[]byte` | `Vec<u8>` | Byte slice |
| `string` | `String` | Owned string |
| `map[string]interface{}` | `HashMap<String, Value>` | JSON object |

### Step 3.4: Implement API Handlers

**Pattern**: Convert REST handlers using dictionary

**Go Original**:
```go
func LoginWithSecret(ctx context.Context, loginRequest LoginRequest) (LoginDetails, error)
```

**Rust Implementation** (dictionary: `api_login_with_secret`):
```rust
// In pyro-core/src/api/handlers.rs
pub async fn api_login_with_secret(
    State(state): State<AppState>,
    Json(req): Json<LoginRequest>,
) -> Result<Json<LoginDetails>, StatusCode>
```

### Step 3.5: Implement Database Layer

**Pattern**: Convert database operations to ReDB

**Go Original**:
```go
func (db *Database) GetUser(ctx context.Context, id uuid.UUID) (*model.User, error)
```

**Rust Implementation** (dictionary: `redb_retrieve_user`):
```rust
// In pyro-core/src/database/mod.rs
pub fn redb_retrieve_user(&self, id: Uuid) -> Result<Option<User>> {
    // Use ReDB to retrieve user
}
```

---

## Phase 4: Integration & Testing

### Step 4.1: Integrate Cryptex Functions

**Action**: Use Cryptex structure as reference

```rust
// Load function from Cryptex
let cryptex = Cryptex::new("./cryptex/pyro")?;
let function = cryptex.get_function("initialize_pyro_server")?;

// Use pseudocode as implementation guide
let pseudocode = function.pseudocode;
// Implement based on pseudocode
```

### Step 4.2: Connect Components

**Pattern**: Use dictionary keys for function calls

```rust
// In pyro-core/src/main.rs
pyro_initialize()?;
pyro_extract_data()?;
pyro_parse_nodes()?;
marshal_orchestrate()?;
bridge_send_message()?;
```

### Step 4.3: Test Individual Functions

**Tool**: Rust unit tests

```rust
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_pyro_initialize() {
        // Test implementation
    }
}
```

### Step 4.4: Integration Testing

**Tool**: API testing

```bash
# Start Pyro server
cargo run --bin pyro

# Test API endpoints
curl http://localhost:3000/health
curl http://localhost:3000/api/cryptex
```

---

## Phase 5: Data Migration

### Step 5.1: Extract BloodHound Data

**Tool**: Data extractor

```rust
// In pyro-core/src/data_extractor.rs
let extracted = BloodHoundExtractor::extract_from_file("bloodhound.json")?;
```

### Step 5.2: Convert to Cryptex Structure

**Action**: Store in Cryptex

```rust
let mut cryptex = Cryptex::new("./cryptex/data")?;
cryptex.add_function(
    None,
    "extract_data".to_string(),
    extracted.to_string(),
    "Extracted BloodHound data".to_string(),
)?;
```

### Step 5.3: Store in ReDB

**Action**: Persist data

```rust
let db = Database::create("./data/pyro.redb")?;
// Store extracted data
```

---

## Phase 6: Node-RED Integration

### Step 6.1: Setup Node-RED Bridge

**Action**: Configure bridge

```rust
let bridge = NodeRedBridge::new()
    .with_http("http://localhost:1880/pyro".to_string());
```

### Step 6.2: Create Data Pipeline

**Action**: Set up pipeline

```rust
let pipeline = PipelineBuilder::new("cryptex")
    .transform("parse")
    .transform("validate")
    .to("node-red")
    .build();
```

### Step 6.3: Send Data to Node-RED

**Action**: Push data through bridge

```rust
let message = NodeRedMessage::new(
    "pyro/data".to_string(),
    json!({"data": extracted_data}),
);
bridge.send(message).await?;
```

---

## Phase 7: Deployment

### Step 7.1: Build Release Binaries

```bash
cargo build --release
```

### Step 7.2: Create Installer (Windows)

```powershell
.\build-installer.ps1 -BuildType release -CreateEXE
```

### Step 7.3: Package for Distribution

```bash
# Create distribution package
mkdir -p dist/pyro
cp target/release/pyro.exe dist/pyro/
cp target/release/fire-marshal.exe dist/pyro/
cp README.md dist/pyro/
```

---

## Complete Workflow Summary

```
┌─────────────────────────────────────────────────────────────┐
│ PHASE 1: ANALYSIS                                            │
│ 1. Analyze codebase structure                                │
│ 2. Extract function inventory                                │
│ 3. Map dependencies                                          │
└─────────────────┬───────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────────────┐
│ PHASE 2: TRANSLATION                                         │
│ 1. Translate to Cryptex structure                            │
│ 2. Apply anarchist naming                                   │
│ 3. Generate pseudocode                                       │
└─────────────────┬───────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────────────┐
│ PHASE 3: RUST IMPLEMENTATION                                 │
│ 1. Review Cryptex functions                                 │
│ 2. Implement in Rust                                         │
│ 3. Use dictionary keys for naming                            │
│ 4. Map Go types to Rust types                               │
└─────────────────┬───────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────────────┐
│ PHASE 4: INTEGRATION                                         │
│ 1. Integrate Cryptex functions                              │
│ 2. Connect components                                        │
│ 3. Test functions                                            │
│ 4. Integration testing                                       │
└─────────────────┬───────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────────────┐
│ PHASE 5: DATA MIGRATION                                      │
│ 1. Extract BloodHound data                                   │
│ 2. Convert to Cryptex                                        │
│ 3. Store in ReDB                                            │
└─────────────────┬───────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────────────┐
│ PHASE 6: NODE-RED INTEGRATION                                │
│ 1. Setup bridge                                             │
│ 2. Create pipelines                                         │
│ 3. Send data                                                │
└─────────────────┬───────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────────────┐
│ PHASE 7: DEPLOYMENT                                          │
│ 1. Build release                                            │
│ 2. Create installer                                          │
│ 3. Package distribution                                      │
└─────────────────────────────────────────────────────────────┘
```

---

## Key Tools & Commands

### MCP Translator
```bash
# Analyze
cargo run --bin mcp-translator < analyze_request.json

# Translate
cargo run --bin mcp-translator < translate_request.json
```

### Pyro Core
```bash
# Run server
cargo run --bin pyro

# Test API
curl http://localhost:3000/health
```

### Fire Marshal
```bash
# Run orchestrator
cargo run --bin fire-marshal
```

### Build & Install
```bash
# Build all
cargo build --release

# Create installer (Windows)
.\build-installer.ps1
```

---

## Dictionary Reference

Use `steering/cryptex-dictionary.md` for:
- Function name lookup
- Pseudocode reference
- Call pattern examples
- Branding term mapping

---

## Troubleshooting

### Translation Issues
- Check file paths are correct
- Verify language parameter matches file type
- Review Cryptex output structure

### Implementation Issues
- Refer to Cryptex pseudocode
- Check dictionary for function names
- Review Go original for logic

### Integration Issues
- Verify all components built
- Check configuration files
- Review API endpoints

---

## Success Criteria

✅ All Go functions translated to Cryptex
✅ Rust implementation complete
✅ Anarchist branding applied
✅ ReDB integration working
✅ Node-RED bridge functional
✅ Data migration successful
✅ Installer created
✅ Documentation complete

---

*"From the ashes of the old, we build the new"* 🔥


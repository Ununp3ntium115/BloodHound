# Implementation Notes

## Rust Implementation Strategy

### Function Naming Convention

All functions use dictionary keys from `cryptex-dictionary.md`:
- Format: `[branding_term]_[function_name]`
- Example: `pyro_initialize`, `marshal_orchestrate`, `cryptex_add_function`

### Code Organization

```
pyro-core/src/
  main.rs           - Entry point
  bootstrap.rs      - Server initialization (from bootstrap/)
  api/              - API handlers (from api/)
  auth/             - Authentication (from auth/)
  database/         - Database layer (from database/)
  services/         - Business logic (from services/)
  model/            - Data models (from model/)
  config.rs         - Configuration (from config/)
```

### Translation Pattern

1. **Extract Go Function**
   ```go
   func NewDaemonContext(parentCtx context.Context) context.Context
   ```

2. **Find Dictionary Key**
   - Look up in `cryptex-dictionary.md`
   - Key: `pyro_create_daemon_context`

3. **Implement in Rust**
   ```rust
   pub fn pyro_create_daemon_context() -> JoinHandle<()>
   ```

4. **Add Pseudocode Comment**
   ```rust
   /// Pseudocode: Create context for background daemon operations
   ```

### Type Mappings

| Go | Rust |
|----|------|
| `context.Context` | `tokio::task::JoinHandle<T>` |
| `error` | `anyhow::Result<T>` |
| `*Database` | `Arc<Database>` |
| `[]byte` | `Vec<u8>` |
| `string` | `String` |
| `map[string]interface{}` | `HashMap<String, Value>` |

### Testing Strategy

1. Unit tests for each function
2. Integration tests for API endpoints
3. End-to-end tests for workflows

---

*Implementation in progress...*


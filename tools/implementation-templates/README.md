# Implementation Templates

🔥 **Templates for Rapid Implementation** 🔥

These templates provide a starting point for implementing new functionality in the Pyro project.

## Available Templates

### 1. Module Template (`module-template.rs`)
Use this when creating a new module or service.

**Features**:
- Configuration structure
- Initialization and shutdown
- Basic structure

**Usage**:
```bash
cp tools/implementation-templates/module-template.rs pyro-core/src/new_module.rs
# Edit the file to match your module
```

### 2. API Handler Template (`api-handler-template.rs`)
Use this when implementing new API endpoints.

**Features**:
- Request/Response structures
- Handler function signature
- Router registration example
- Test structure

**Usage**:
```bash
cp tools/implementation-templates/api-handler-template.rs pyro-core/src/api/v2/new_handler.rs
# Edit the file to match your endpoint
```

### 3. Database Model Template (`database-model-template.rs`)
Use this when creating new database models.

**Features**:
- Model structure with common fields
- Repository trait
- ReDB implementation example
- CRUD operations
- Validation

**Usage**:
```bash
cp tools/implementation-templates/database-model-template.rs pyro-core/src/database/new_model.rs
# Edit the file to match your model
```

## Implementation Workflow

1. **Identify what to implement**:
   ```bash
   ./scripts/agent-plan.sh auth
   ```

2. **Choose appropriate template**

3. **Copy template**:
   ```bash
   cp tools/implementation-templates/api-handler-template.rs pyro-core/src/api/v2/my_handler.rs
   ```

4. **Implement functionality**:
   - Replace TODOs with actual code
   - Translate from Go codebase
   - Apply Pyro branding

5. **Update task status**:
   ```bash
   ./scripts/agent-update.sh auth auth_Login Completed
   ```

6. **Test implementation**:
   ```bash
   cargo test --package pyro-core
   ```

## Template Customization

All templates include:
- ✅ Proper error handling
- ✅ Serialization/Deserialization
- ✅ Test structure
- ✅ Documentation placeholders
- ✅ Pyro branding comments

## Best Practices

1. **Follow the template structure** - Don't skip sections
2. **Replace all TODOs** - Don't leave placeholder code
3. **Write tests** - Use the test structure provided
4. **Update agents** - Mark tasks as completed
5. **Document** - Add comments explaining complex logic

## Examples

See existing implementations:
- `pyro-core/src/api/handlers.rs` - API handlers
- `pyro-core/src/auth/handlers.rs` - Auth handlers
- `pyro-core/src/database/models.rs` - Database models

---

*Use these templates to accelerate implementation while maintaining consistency*


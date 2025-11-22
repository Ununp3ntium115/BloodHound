# PYRO Detector - Testing and Logging Implementation Plan

## Technology Stack (CORRECTED)

✅ **Rust** - Backend API (pyro-core with Axum)  
✅ **RedB** - Database  
✅ **Node-RED** - Orchestration  
✅ **Svelte** - Frontend (needs to be created/converted)  
✅ **Cryptex** - Function organization  

## Implementation Plan

### Phase 1: Rust Backend API (pyro-core)
1. Add PYRO Detector API handlers to `pyro-core/src/api/handlers.rs`
2. Use Axum for HTTP routing
3. Integrate with existing MCP server (pyro-detector)
4. Add comprehensive logging using Rust tracing
5. Use RedB for data persistence
6. Use Cryptex for function organization

### Phase 2: Enhanced Logging
1. **Rust MCP Server**: File-based structured logging with rotation ✅ (already done)
2. **Rust Backend API**: Request/response logging, performance metrics
3. **Svelte Frontend**: User action logging, API call tracking, error logging

### Phase 3: Svelte Frontend
1. Create SvelteKit application structure
2. Convert React components to Svelte
3. Implement API client in TypeScript
4. Add comprehensive UI logging
5. Integrate with Rust backend

### Phase 4: Testing Framework
1. Create 30+ test scripts (Rust integration tests)
2. Create UA testing framework
3. Create issue tracking system
4. Set up test execution and reporting

### Phase 5: Signed Executable
1. Create build process for signed executable
2. Code signing setup
3. Distribution packaging

## Next Steps

1. ✅ Enhanced Rust MCP logging (completed)
2. ⏳ Create Rust backend API in pyro-core
3. ⏳ Create Svelte frontend
4. ⏳ Add comprehensive logging to all components
5. ⏳ Create 30+ test scripts
6. ⏳ Create signed executable build


# Implementation Guide - Pyro Project

🔥 **Comprehensive Implementation Guide with Mitigation Strategies** 🔥

This guide provides detailed implementation strategies for each module identified in the gap analysis.

---

## Table of Contents

1. [API Module](#api-module)
2. [Auth Module](#auth-module)
3. [Database Module](#database-module)
4. [Graphify Module](#graphify-module)
5. [Data Pipeline Module](#data-pipeline-module)
6. [Upload Module](#upload-module)
7. [Queries Module](#queries-module)
8. [Analysis Module](#analysis-module)
9. [General Implementation Patterns](#general-implementation-patterns)

---

## API Module

### Current Status
- ✅ Basic handlers exist (`pyro-core/src/api/handlers.rs`)
- ✅ Middleware structure exists (`pyro-core/src/api/middleware.rs`)
- ❌ V2 API endpoints missing (255 functions)
- ❌ Middleware implementation incomplete
- ❌ Static file serving missing
- ❌ CSV export missing

### Implementation Strategy

#### Phase 1: Core V2 Endpoints (Priority: Critical)

**Files to Translate**:
- `cmd/api/src/api/v2/users.go`
- `cmd/api/src/api/v2/sessions.go`
- `cmd/api/src/api/v2/queries.go`

**Steps**:
1. Extract function signatures from Go files
2. Create Rust equivalents in `pyro-core/src/api/v2/`
3. Implement handlers using Axum
4. Add route registration

**Example Translation**:
```rust
// Go: cmd/api/src/api/v2/users.go
func GetUsers(c *gin.Context) { ... }

// Rust: pyro-core/src/api/v2/users.rs
pub async fn get_users(
    State(state): State<AppState>,
    Query(params): Query<UserQueryParams>,
) -> Result<Json<UserListResponse>, StatusCode> {
    // Implementation
}
```

#### Phase 2: Middleware Stack (Priority: Critical)

**Files to Translate**:
- `cmd/api/src/api/middleware/auth.go`
- `cmd/api/src/api/middleware/logging.go`
- `cmd/api/src/api/middleware/error.go`

**Steps**:
1. Create tower middleware layers
2. Implement authentication middleware
3. Add logging middleware
4. Add error handling middleware

**Example**:
```rust
// pyro-core/src/api/middleware.rs
pub fn auth_middleware() -> tower::ServiceBuilder<...> {
    ServiceBuilder::new()
        .layer(auth_layer())
        .layer(logging_layer())
}
```

#### Phase 3: Graph Query Endpoints (Priority: High)

**Files to Translate**:
- `cmd/api/src/api/v2/graph.go`
- `cmd/api/src/api/v2/attackpaths.go`

**Steps**:
1. Implement graph query handlers
2. Add attack path analysis endpoints
3. Connect to graph database

#### Phase 4: Analysis Endpoints (Priority: Medium)

**Files to Translate**:
- `cmd/api/src/api/agi.go`
- `cmd/api/src/api/v2/analysis.go`

**Steps**:
1. Implement AGI endpoints
2. Add analysis request handlers
3. Add result formatting

### Mitigation Strategies

1. **Incremental Implementation**: Start with most-used endpoints
2. **API Compatibility**: Maintain backward compatibility
3. **Testing**: Write integration tests for each endpoint
4. **Documentation**: Document API changes

### Dependencies

- Database module (for data access)
- Auth module (for authentication)
- Queries module (for graph queries)

---

## Auth Module

### Current Status
- ✅ Basic login/logout exists
- ✅ Session management (partial)
- ❌ TOTP missing
- ❌ SAML missing
- ❌ OIDC missing
- ❌ Permission system missing

### Implementation Strategy

#### Phase 1: Complete Session Management (Priority: Critical)

**Files to Translate**:
- `cmd/api/src/auth/model.go`
- `cmd/api/src/auth/session.go` (if exists)

**Steps**:
1. Complete session storage
2. Add session expiration handling
3. Implement session refresh
4. Add session cleanup

#### Phase 2: TOTP Implementation (Priority: High)

**Files to Translate**:
- `cmd/api/src/auth/totp.go`

**Steps**:
1. Add TOTP secret generation
2. Implement TOTP validation
3. Add QR code generation
4. Update login flow

**Example**:
```rust
// pyro-core/src/auth/totp.rs
pub struct TotpService {
    // Implementation
}

impl TotpService {
    pub fn generate_secret(&self) -> String { ... }
    pub fn validate(&self, secret: &str, code: &str) -> bool { ... }
}
```

#### Phase 3: SAML Integration (Priority: Medium)

**Files to Translate**:
- `cmd/api/src/auth/saml.go`
- `cmd/api/src/services/saml/`

**Steps**:
1. Implement SAML assertion parsing
2. Add SAML provider configuration
3. Implement SSO flow
4. Add user mapping

#### Phase 4: OIDC Integration (Priority: Medium)

**Files to Translate**:
- `cmd/api/src/services/oidc/`

**Steps**:
1. Implement OIDC client
2. Add provider discovery
3. Implement token exchange
4. Add user info retrieval

#### Phase 5: Permission System (Priority: High)

**Files to Translate**:
- `cmd/api/src/auth/permission.go`
- `cmd/api/src/auth/role.go`

**Steps**:
1. Implement permission model
2. Add role-based access control
3. Create permission middleware
4. Add permission checks to endpoints

### Mitigation Strategies

1. **Security First**: Security review for all auth code
2. **Standards Compliance**: Follow OAuth2, SAML, OIDC standards
3. **Testing**: Comprehensive security testing
4. **Documentation**: Document auth flows

### Dependencies

- Database module (for user/session storage)
- Crypto utilities (for password hashing, TOTP)

---

## Database Module

### Current Status
- ✅ Basic models exist
- ✅ ReDB integration (partial)
- ❌ Migration system missing
- ❌ Audit logging missing
- ❌ Many models missing

### Implementation Strategy

#### Phase 1: Migration System (Priority: Critical)

**Files to Translate**:
- `cmd/api/src/database/migration/` (47 SQL files + Go code)

**Steps**:
1. Create migration runner
2. Implement SQL migration execution
3. Add migration version tracking
4. Create migration rollback capability

**Example**:
```rust
// pyro-core/src/database/migrations.rs
pub struct MigrationRunner {
    db: Database,
}

impl MigrationRunner {
    pub async fn run_migrations(&self) -> Result<()> {
        // Execute SQL migrations in order
    }
}
```

#### Phase 2: Complete Models (Priority: High)

**Files to Translate**:
- `cmd/api/src/database/*.go` (all model files)
- `cmd/api/src/model/*.go`

**Steps**:
1. Translate each model to Rust structs
2. Implement database operations (CRUD)
3. Add validation
4. Add relationships

**Example**:
```rust
// pyro-core/src/database/models.rs
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct User {
    pub id: Uuid,
    pub principal_name: String,
    pub email_address: Option<String>,
    // ... other fields
}
```

#### Phase 3: Audit Logging (Priority: High)

**Files to Translate**:
- `cmd/api/src/database/audit.go`

**Steps**:
1. Create audit log model
2. Implement audit logging functions
3. Add audit log queries
4. Create audit log viewer

#### Phase 4: Data Quality Tracking (Priority: Medium)

**Files to Translate**:
- `cmd/api/src/database/dataquality.go`
- `cmd/api/src/services/dataquality/`

**Steps**:
1. Implement data quality models
2. Add quality metrics calculation
3. Create quality reports
4. Add quality monitoring

### Mitigation Strategies

1. **Migration Safety**: Test migrations on sample data first
2. **Data Integrity**: Validate all data operations
3. **Performance**: Optimize queries and indexes
4. **Backup**: Ensure data backup before migrations

### Dependencies

- ReDB or PostgreSQL (database backend)
- Migration system (for schema changes)

---

## Graphify Module

### Current Status
- ❌ Not implemented
- ⏳ Fire Marshal has basic structure

### Implementation Strategy

#### Phase 1: Basic Graph Ingestion (Priority: Critical)

**Files to Translate**:
- `cmd/api/src/services/graphify/` (83 files)

**Steps**:
1. Implement graph data parser
2. Create node converters
3. Create edge converters
4. Add validation

**Example**:
```rust
// fire-marshal/src/graphify/mod.rs
pub struct GraphIngester {
    db: GraphDatabase,
}

impl GraphIngester {
    pub async fn ingest(&self, data: &Value) -> Result<()> {
        // Parse and ingest graph data
    }
}
```

#### Phase 2: Node Type Converters (Priority: High)

**Steps**:
1. Implement converters for each node type:
   - Users
   - Computers
   - Groups
   - Domains
   - OUs
   - GPOs
   - etc.

#### Phase 3: Edge/Relationship Processing (Priority: High)

**Steps**:
1. Implement relationship converters
2. Add relationship validation
3. Create relationship indexes

#### Phase 4: Schema Validation (Priority: Medium)

**Steps**:
1. Implement schema validation
2. Add data quality checks
3. Create validation reports

### Mitigation Strategies

1. **Incremental**: Start with most common node types
2. **Performance**: Batch operations for large datasets
3. **Error Handling**: Robust error recovery
4. **Testing**: Test with real BloodHound data

### Dependencies

- Graph database (Neo4j/PostgreSQL)
- Fire Marshal (orchestration)
- Upload module (data source)

---

## Data Pipeline Module

### Current Status
- ⏳ Basic structure in Fire Marshal
- ❌ Complete orchestration missing
- ❌ Job queue missing

### Implementation Strategy

#### Phase 1: Pipeline Orchestration (Priority: Critical)

**Files to Translate**:
- `cmd/api/src/daemons/datapipe/` (27 files)

**Steps**:
1. Implement pipeline runner
2. Add job queue
3. Create status tracking
4. Add error handling

**Example**:
```rust
// fire-marshal/src/orchestrator.rs
pub struct PipelineOrchestrator {
    queue: JobQueue,
    workers: Vec<Worker>,
}

impl PipelineOrchestrator {
    pub async fn run_pipeline(&self, pipeline: Pipeline) -> Result<()> {
        // Orchestrate pipeline execution
    }
}
```

#### Phase 2: Job Queue System (Priority: High)

**Steps**:
1. Implement job queue (Redis or in-memory)
2. Add job prioritization
3. Create worker pool
4. Add job retry logic

#### Phase 3: Status Tracking (Priority: High)

**Steps**:
1. Implement status storage
2. Add progress tracking
3. Create status API
4. Add status notifications

#### Phase 4: Error Recovery (Priority: Medium)

**Steps**:
1. Implement error logging
2. Add retry mechanisms
3. Create error notifications
4. Add dead letter queue

### Mitigation Strategies

1. **Reliability**: Ensure job persistence
2. **Scalability**: Design for horizontal scaling
3. **Monitoring**: Add comprehensive monitoring
4. **Testing**: Test failure scenarios

### Dependencies

- Fire Marshal (orchestration framework)
- Database (for status storage)
- Graphify (for data processing)

---

## Upload Module

### Current Status
- ❌ Not implemented

### Implementation Strategy

#### Phase 1: File Upload Handling (Priority: High)

**Files to Translate**:
- `cmd/api/src/services/upload/` (13 files)

**Steps**:
1. Implement file upload endpoint
2. Add file validation
3. Create temporary storage
4. Add progress tracking

#### Phase 2: ZIP Extraction (Priority: High)

**Steps**:
1. Implement ZIP extraction
2. Add file validation
3. Create extraction pipeline
4. Add error handling

#### Phase 3: Data Validation (Priority: High)

**Steps**:
1. Implement schema validation
2. Add data quality checks
3. Create validation reports
4. Add error reporting

### Mitigation Strategies

1. **Security**: Validate all uploads
2. **Performance**: Stream large files
3. **Error Handling**: Clear error messages
4. **Testing**: Test with various file types

### Dependencies

- API module (for endpoints)
- Graphify (for data processing)
- Fire Marshal (for orchestration)

---

## Queries Module

### Current Status
- ❌ Not implemented

### Implementation Strategy

#### Phase 1: Basic Query Execution (Priority: High)

**Files to Translate**:
- `cmd/api/src/queries/graph.go`

**Steps**:
1. Implement Cypher query execution
2. Add query validation
3. Create result formatting
4. Add error handling

#### Phase 2: Query Rewriting (Priority: Medium)

**Files to Translate**:
- `cmd/api/src/queries/rewriter.go`

**Steps**:
1. Implement query optimization
2. Add security checks
3. Create query rewriting rules
4. Add query caching

#### Phase 3: Advanced Queries (Priority: Medium)

**Steps**:
1. Implement complex queries
2. Add aggregation
3. Create query builder
4. Add query templates

### Mitigation Strategies

1. **Security**: Prevent injection attacks
2. **Performance**: Optimize queries
3. **Caching**: Cache frequent queries
4. **Testing**: Test with various query types

### Dependencies

- Graph database (Neo4j/PostgreSQL)
- Database module (for query storage)

---

## Analysis Module

### Current Status
- ❌ Not implemented

### Implementation Strategy

#### Phase 1: AD Analysis (Priority: High)

**Files to Translate**:
- `cmd/api/src/analysis/ad/` (5 files)

**Steps**:
1. Implement AD analysis algorithms
2. Add cross-product calculations
3. Create analysis results
4. Add result caching

#### Phase 2: Azure Analysis (Priority: Medium)

**Files to Translate**:
- `cmd/api/src/analysis/azure/` (5 files)

**Steps**:
1. Implement Azure analysis algorithms
2. Add Azure-specific calculations
3. Create Azure analysis results

#### Phase 3: Hybrid Analysis (Priority: Low)

**Files to Translate**:
- `cmd/api/src/analysis/hybrid/`

**Steps**:
1. Implement hybrid analysis
2. Combine AD and Azure results
3. Create unified analysis

### Mitigation Strategies

1. **Accuracy**: Ensure algorithm correctness
2. **Performance**: Optimize calculations
3. **Testing**: Test with real data
4. **Documentation**: Document algorithms

### Dependencies

- Graph database (for data access)
- Queries module (for data retrieval)

---

## General Implementation Patterns

### Code Translation Pattern

1. **Analyze Go Code**:
   ```bash
   cargo run --bin mcp-translator <<EOF
   {
     "jsonrpc": "2.0",
     "id": 1,
     "method": "extract_functions",
     "params": {
       "file_path": "./cmd/api/src/api/auth.go",
       "language": "go"
     }
   }
   EOF
   ```

2. **Translate to Rust**:
   - Convert Go types to Rust types
   - Convert Go error handling to Rust Result
   - Convert Go concurrency to Rust async/await
   - Apply Pyro branding

3. **Test Implementation**:
   - Write unit tests
   - Write integration tests
   - Test error cases

4. **Update Progress**:
   ```bash
   cargo run --bin mcp-translator <<EOF
   {
     "jsonrpc": "2.0",
     "id": 2,
     "method": "update_task_status",
     "params": {
       "module": "auth",
       "task_id": "auth_login",
       "status": "Completed"
     }
   }
   EOF
   ```

### Testing Strategy

1. **Unit Tests**: Test individual functions
2. **Integration Tests**: Test module interactions
3. **E2E Tests**: Test complete workflows
4. **Performance Tests**: Test performance characteristics

### Documentation Strategy

1. **Code Comments**: Document all public functions
2. **API Documentation**: Document all endpoints
3. **Architecture Docs**: Document system design
4. **User Guides**: Document user workflows

---

## Iteration Plan

### Week 1-2: Foundation
- Complete auth module (Phase 1-2)
- Complete database migrations
- Set up testing framework

### Week 3-4: Core Features
- Implement graphify (Phase 1)
- Implement upload module
- Complete data pipeline (Phase 1-2)

### Week 5-6: API Expansion
- Implement V2 API endpoints (Phase 1-2)
- Add middleware stack
- Implement graph queries

### Week 7-8: Advanced Features
- Complete analysis module
- Add SAML/OIDC
- Complete permission system

### Week 9+: Polish
- Performance optimization
- Security audit
- Documentation
- Deployment

---

*This guide is a living document. Update as implementation progresses.*


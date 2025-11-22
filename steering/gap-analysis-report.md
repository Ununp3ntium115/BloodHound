# Gap Analysis Report

## Overview

This report shows the gap between BloodHound Go source code and BloodSniffer Rust implementation.

## How to Generate

```bash
python - <<'PY'
import subprocess, json
req = {
    "jsonrpc": "2.0",
    "id": 1,
    "method": "gap_analysis",
    "params": {
        "go_source_path": "./cmd/api/src",
        "rust_source_path": "./pyro-core/src"
    }
}
subprocess.run(
    ["cargo", "run", "--bin", "mcp-translator"],
    cwd="E:/GitRepos/Bloodhound/BloodHound",
    input=json.dumps(req) + "\n",
    text=True,
    check=True,
)
PY
```

## Report Structure

- **Coverage**: Overall implementation coverage percentage
- **Missing Functions**: Functions in Go but not in Rust
- **Extra Functions**: Functions in Rust but not in Go
- **Module Analysis**: Coverage by module

## Action Items

Based on gap analysis:

1. Implement missing functions
2. Review extra functions (may be new features)
3. Improve module coverage
4. Update tests

## Latest Run (2025-11-22)

- **Coverage**: 67 Rust functions mapped vs 1,596 in Go (≈4.2% coverage).
- **Missing Functions**: 1,595 gaps remaining (no extras yet).
- **Highest-gap modules**: `v2` (255 fns), `graphify` (141), `auth` (137), `database` (87), `api` (85), `ad` (85), `datapipe` (46), `upload` (39), `queries` (48), `config` (25), `utils` (36).
- **Critical services absent**: graph ingestion pipeline, auth middleware stack, Node-RED/graph DB daemons, config/validation services, and all integration/UA tests.

### Immediate Mitigations

1. **Auth & API parity**
   - Port `api/auth.go`, middleware, and session validation flows into `pyro-core`.
   - Wire the existing Axum middleware (`api/middleware.rs`) as tower layers guarding every route except health/login.
   - Mirror password/TOTP policies and validator helpers from `utils/validation`.

2. **Graphify + Pipeline**
   - Implement real BloodHound ingestion: `services/graphify` converters, decoders, and ingest orchestrators must be translated into `fire-marshal` + Cryptex nodes.
   - Connect to Neo4j/PG via `fire-marshal` graph clients; current stubs in `bootstrap::bloodsniffer_connect_graph` need concrete drivers and health probes.
   - Expand the new pipeline registry + Fire Marshal worker into a fully validated upload path (ZIP validation, schema checks, ingest job lifecycle).

3. **Database + Config**
   - Port `database/*.go` models and migrations into `pyro-core::database`, matching installation flows, audit logging, feature flags, and saved query storage.
   - Translate `config/default.go` + validators so the Rust config matches every server/env toggle (ingest size limits, graph options, daemons, etc.).

4. **Upload/Data pipeline**
   - Move the JSON/ZIP ingest validators (`services/upload`, `utils/validation`) and pipeline orchestration (`daemons/datapipe`) into `fire-marshal`.
   - Ensure Cryptex extraction writes to the same metadata shape `upload` expects so Node-RED agents can reuse flows.

5. **Testing & tooling**
   - Rebuild regression suites: unit (validators, auth, ingest), integration (graph API), UA workflows (upload → analysis).
   - Extend the MCP translator with module-specific agents (e.g., `graphify-agent`, `auth-agent`) to track translation status automatically.

Document owner: Fire Marshal engineering. Update after each MCP gap-analysis run.

---

*Generated automatically by MCP Gap Analyzer*


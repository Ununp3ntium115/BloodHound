# Fire Marshal Readiness Audit

Autonomous objective: deliver BloodSniffer as a fully weaponized Pyro stack. This document captures the current confidence level, gaps, and the ignition path to 100% production readiness.

## Mission Objectives Snapshot

- Phase completion counts mirror the master tracker: Core 8/26, Testing 2/23, Integration 0/21, Pipeline 0/16, Polish 0/29, giving an overall ~15% completion rate.  
- Current critical priorities remain: clear compilation blockers, complete the API handler set, wire middleware, build services, run integration tests, finish Node-RED + graph integrations, finalize documentation.

## Gap Analysis

1. **Core stability** – Several handlers were referencing session fields that the `Session` type never exposed, which would prevent the binary from compiling. We normalized the session struct and JWT creation logic so that authentication can actually build and run.
2. **Secret management** – JWT signing previously relied on a hard-coded secret. Secrets now come from configuration/environment (`auth.jwt_secret`), but we still need rotation tooling, per-environment values, and infra automation to load them securely.
3. **Access control** – Auth middleware exists but is not mounted on any routes, so every endpoint except login remains publicly writable. We need to attach the middleware to the protected route group and add role-aware guards before exposing these APIs.
4. **Data path completeness** – Extraction and pipeline handlers still emit placeholder Cryptex nodes (`todo!()` bodies) and never persist pipeline definitions or stream them into Fire Marshal. Until we build real parsing, validation, and persistence this path is not production ready.
5. **Graph/Node-RED orchestration** – `bloodsniffer_connect_graph` is a stub and Node-RED messaging is fire-and-forget with no health checks or retries. Production needs connection pooling, circuit breaking, back-pressure, and telemetry.
6. **Testing & docs** – Only two unit-test suites exist, integration/UA tests plus documentation remain at zero, so we have no safety net or onboarding story.

## Priority Path to 100%

1. **Stabilize & secure (now)**
   - Enforce authentication middleware on every sensitive route, add session cleanup jobs, and introduce configurable password/JWT policies.
   - Replace hard-coded demo defaults (admin password, ports, directories) with environment-specific overrides and secrets management.
2. **Complete core flows (next)**
   - Finish the remaining API handlers and services, especially pipeline orchestration, Cryptex CRUD, and auth role management.
   - Implement the real BloodHound extraction logic plus Fire Marshal persistence so data flows through Cryptex → Fire Marshal → Node-RED.
3. **Integrations & observability (then)**
   - Build the graph DB connector (Neo4j/Postgres) with migrations, seeders, and health endpoints.
   - Harden Node-RED bridge with retries, metrics, tracing, and configuration validation.
4. **Quality gates (always)**
   - Add integration/UA tests that cover login, Cryptex CRUD, extraction, and pipeline creation.
   - Flesh out anarchist-themed runbooks, deployment docs, and MCP translator workflows so teams can operate the system autonomously.

Document owner: Fire Marshal engineering. Update every sprint as we burn down the readiness gap.


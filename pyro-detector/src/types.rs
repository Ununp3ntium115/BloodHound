use serde::{Deserialize, Serialize};
use chrono::{DateTime, Utc};

/// Investigation case (CDIF: Case)
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct InvestigationCase {
    pub case_id: String,
    pub case_number: Option<String>,
    pub case_name: String,
    pub investigation_type: String,
    pub priority: String,
    pub status: String,
    pub investigator: Option<Investigator>,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

/// Investigator information
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Investigator {
    pub name: String,
    pub badge_number: Option<String>,
    pub certification: Option<String>,
}

/// Detonator (CDIF: Detonator, NOT "artifact")
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Detonator {
    pub id: String,
    pub name: String,
    pub description: Option<String>,
    pub investigation_type: Option<String>,
    pub category: Option<String>,
    pub platform: Option<String>,
    pub fire_marshal_certified: bool,
    pub performance: Option<PerformanceMetrics>,
}

/// Performance metrics
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PerformanceMetrics {
    pub execution_time_ms: Option<u64>,
    pub improvement_factor: Option<String>,
    pub memory_usage_mb: Option<u64>,
}

/// Detonator execution request
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DetonatorExecutionRequest {
    pub detonator_id: String,
    pub investigation_type: Option<String>,
    pub target_systems: Option<Vec<String>>,
    pub parameters: Option<serde_json::Value>,
    pub evidence_chain: Option<EvidenceChain>,
    pub case_id: Option<String>,
}

/// Evidence chain (CDIF: Evidence Chain)
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct EvidenceChain {
    pub case_id: Option<String>,
    pub investigator: Option<String>,
    pub location: Option<String>,
    pub quantum_verification: Option<bool>,
}

/// Detonator execution result
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DetonatorExecutionResult {
    pub execution_id: String,
    pub detonator: Detonator,
    pub investigation_results: Option<InvestigationResults>,
    pub fire_marshal_certified: bool,
    pub timestamp: DateTime<Utc>,
}

/// Investigation results
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct InvestigationResults {
    pub findings: Vec<Finding>,
    pub evidence_chain: Option<EvidenceChainInfo>,
}

/// Finding from investigation
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Finding {
    pub severity: String,
    pub r#type: String,
    pub description: Option<String>,
    pub data: Option<serde_json::Value>,
}

/// Evidence chain information
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct EvidenceChainInfo {
    pub quantum_verification: Option<String>,
    pub chain_integrity: Option<String>,
    pub court_admissible: Option<bool>,
}

/// Agent (CDIF: Agent, NOT "client")
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Agent {
    pub agent_id: String,
    pub name: Option<String>,
    pub platform: Option<String>,
    pub status: String,
    pub last_seen: Option<DateTime<Utc>>,
    pub capabilities: Option<Vec<String>>,
}

/// PQL Query request
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PqlQueryRequest {
    pub query: String,
    pub target_agents: Option<Vec<String>>,
    pub timeout_seconds: Option<u64>,
    pub max_results: Option<u64>,
}

/// PQL Query result
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PqlQueryResult {
    pub query_id: String,
    pub status: String,
    pub results: Option<Vec<serde_json::Value>>,
    pub progress: Option<f64>,
    pub error: Option<String>,
}

/// API Error response
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ApiError {
    pub error: ErrorDetails,
    pub investigation_context: Option<InvestigationContext>,
}

/// Error details
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ErrorDetails {
    pub code: String,
    pub message: String,
    pub details: Option<String>,
    pub timestamp: Option<DateTime<Utc>>,
    pub trace_id: Option<String>,
}

/// Investigation context
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct InvestigationContext {
    pub case_id: Option<String>,
    pub detonator_id: Option<String>,
    pub execution_id: Option<String>,
}


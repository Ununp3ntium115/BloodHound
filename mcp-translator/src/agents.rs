use anyhow::{Context, Result};
use serde::{Deserialize, Serialize};
use std::collections::HashMap;

use crate::gap_analysis::GapAnalysis;

/// Agent for tracking and implementing missing functionality
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ImplementationAgent {
    pub name: String,
    pub module: String,
    pub status: AgentStatus,
    pub priority: Priority,
    pub tasks: Vec<AgentTask>,
    pub progress: f64,
}

/// Agent status
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
pub enum AgentStatus {
    Pending,
    InProgress,
    Blocked,
    Completed,
    Review,
}

/// Task priority
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq, PartialOrd, Ord)]
pub enum Priority {
    Critical,
    High,
    Medium,
    Low,
}

/// Individual task for an agent
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AgentTask {
    pub id: String,
    pub description: String,
    pub go_file: String,
    pub rust_file: Option<String>,
    pub functions: Vec<String>,
    pub status: TaskStatus,
    pub dependencies: Vec<String>,
}

/// Task status
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
pub enum TaskStatus {
    NotStarted,
    InProgress,
    Completed,
    Blocked,
}

/// Agent registry for managing all implementation agents
pub struct AgentRegistry {
    agents: HashMap<String, ImplementationAgent>,
}

impl AgentRegistry {
    /// Create new agent registry
    pub fn new() -> Self {
        Self {
            agents: HashMap::new(),
        }
    }

    /// Create agents from gap analysis
    pub fn from_gap_analysis(analysis: &GapAnalysis) -> Self {
        let mut registry = Self::new();

        // Group missing functions by module
        let mut module_functions: HashMap<String, Vec<&crate::gap_analysis::FunctionInfo>> =
            HashMap::new();

        for func in &analysis.missing_functions {
            module_functions
                .entry(func.module.clone())
                .or_insert_with(Vec::new)
                .push(func);
        }

        // Create agents for each module
        for (module, functions) in module_functions {
            let priority = Self::determine_priority(&module, functions.len());
            let tasks = functions
                .iter()
                .map(|f| AgentTask {
                    id: format!("{}_{}", module, f.name),
                    description: format!("Implement {}", f.name),
                    go_file: f.file_path.clone(),
                    rust_file: None,
                    functions: vec![f.name.clone()],
                    status: TaskStatus::NotStarted,
                    dependencies: vec![],
                })
                .collect();

            let agent = ImplementationAgent {
                name: format!("{}_agent", module),
                module: module.clone(),
                status: AgentStatus::Pending,
                priority,
                tasks,
                progress: 0.0,
            };

            registry.agents.insert(module.clone(), agent);
        }

        registry
    }

    /// Determine priority based on module and function count
    fn determine_priority(module: &str, function_count: usize) -> Priority {
        match module {
            "auth" | "api" | "bootstrap" => Priority::Critical,
            "database" | "config" => Priority::High,
            "graphify" | "datapipe" | "upload" => {
                if function_count > 50 {
                    Priority::High
                } else {
                    Priority::Medium
                }
            }
            _ => {
                if function_count > 100 {
                    Priority::High
                } else if function_count > 50 {
                    Priority::Medium
                } else {
                    Priority::Low
                }
            }
        }
    }

    /// Get agent by module name
    pub fn get_agent(&self, module: &str) -> Option<&ImplementationAgent> {
        self.agents.get(module)
    }

    /// Get all agents
    pub fn get_all_agents(&self) -> Vec<&ImplementationAgent> {
        self.agents.values().collect()
    }

    /// Get agents by priority
    pub fn get_agents_by_priority(&self, priority: Priority) -> Vec<&ImplementationAgent> {
        self.agents
            .values()
            .filter(|a| a.priority == priority)
            .collect()
    }

    /// Update agent status
    pub fn update_agent_status(&mut self, module: &str, status: AgentStatus) -> Result<()> {
        let agent = self
            .agents
            .get_mut(module)
            .context(format!("Agent not found: {}", module))?;
        agent.status = status;
        Ok(())
    }

    /// Update task status
    pub fn update_task_status(
        &mut self,
        module: &str,
        task_id: &str,
        status: TaskStatus,
    ) -> Result<()> {
        let agent = self
            .agents
            .get_mut(module)
            .context(format!("Agent not found: {}", module))?;

        let task = agent
            .tasks
            .iter_mut()
            .find(|t| t.id == task_id)
            .context(format!("Task not found: {}", task_id))?;

        task.status = status;

        // Update agent progress
        let completed = agent.tasks.iter().filter(|t| t.status == TaskStatus::Completed).count();
        agent.progress = (completed as f64 / agent.tasks.len() as f64) * 100.0;

        // Update agent status based on progress
        if agent.progress == 100.0 {
            agent.status = AgentStatus::Completed;
        } else if agent.progress > 0.0 {
            agent.status = AgentStatus::InProgress;
        }

        Ok(())
    }

    /// Get implementation roadmap
    pub fn get_roadmap(&self) -> ImplementationRoadmap {
        let mut critical = Vec::new();
        let mut high = Vec::new();
        let mut medium = Vec::new();
        let mut low = Vec::new();

        for agent in self.agents.values() {
            let summary = AgentSummary {
                name: agent.name.clone(),
                module: agent.module.clone(),
                status: agent.status.clone(),
                progress: agent.progress,
                total_tasks: agent.tasks.len(),
                completed_tasks: agent
                    .tasks
                    .iter()
                    .filter(|t| t.status == TaskStatus::Completed)
                    .count(),
            };

            match agent.priority {
                Priority::Critical => critical.push(summary),
                Priority::High => high.push(summary),
                Priority::Medium => medium.push(summary),
                Priority::Low => low.push(summary),
            }
        }

        ImplementationRoadmap {
            critical,
            high,
            medium,
            low,
        }
    }
}

impl Default for AgentRegistry {
    fn default() -> Self {
        Self::new()
    }
}

/// Agent summary for roadmap
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AgentSummary {
    pub name: String,
    pub module: String,
    pub status: AgentStatus,
    pub progress: f64,
    pub total_tasks: usize,
    pub completed_tasks: usize,
}

/// Implementation roadmap organized by priority
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ImplementationRoadmap {
    pub critical: Vec<AgentSummary>,
    pub high: Vec<AgentSummary>,
    pub medium: Vec<AgentSummary>,
    pub low: Vec<AgentSummary>,
}

/// Generate implementation plan for a specific module
pub fn generate_implementation_plan(
    module: &str,
    analysis: &GapAnalysis,
) -> Result<ModuleImplementationPlan> {
    let module_analysis = analysis
        .modules
        .iter()
        .find(|m| m.module_name == module)
        .context(format!("Module not found: {}", module))?;

    let missing_functions: Vec<_> = analysis
        .missing_functions
        .iter()
        .filter(|f| f.module == module)
        .collect();

    // Group by file
    let mut file_groups: HashMap<String, Vec<&crate::gap_analysis::FunctionInfo>> =
        HashMap::new();
    for func in &missing_functions {
        file_groups
            .entry(func.file_path.clone())
            .or_insert_with(Vec::new)
            .push(func);
    }

    let phases = vec![
        ImplementationPhase {
            phase: 1,
            name: "Core Functions".to_string(),
            description: "Implement essential functions for module operation".to_string(),
            functions: missing_functions
                .iter()
                .take(missing_functions.len() / 3)
                .map(|f| f.name.clone())
                .collect(),
        },
        ImplementationPhase {
            phase: 2,
            name: "Supporting Functions".to_string(),
            description: "Implement supporting and utility functions".to_string(),
            functions: missing_functions
                .iter()
                .skip(missing_functions.len() / 3)
                .take(missing_functions.len() / 3)
                .map(|f| f.name.clone())
                .collect(),
        },
        ImplementationPhase {
            phase: 3,
            name: "Integration Functions".to_string(),
            description: "Implement integration and edge case functions".to_string(),
            functions: missing_functions
                .iter()
                .skip(2 * missing_functions.len() / 3)
                .map(|f| f.name.clone())
                .collect(),
        },
    ];

    Ok(ModuleImplementationPlan {
        module: module.to_string(),
        total_functions: module_analysis.total_functions,
        missing_functions: module_analysis.missing,
        coverage: module_analysis.coverage_percent,
        phases,
        file_groups: file_groups
            .into_iter()
            .map(|(file, funcs)| (file, funcs.len()))
            .collect(),
    })
}

/// Implementation plan for a specific module
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ModuleImplementationPlan {
    pub module: String,
    pub total_functions: usize,
    pub missing_functions: usize,
    pub coverage: f64,
    pub phases: Vec<ImplementationPhase>,
    pub file_groups: HashMap<String, usize>,
}

/// Implementation phase
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ImplementationPhase {
    pub phase: u32,
    pub name: String,
    pub description: String,
    pub functions: Vec<String>,
}


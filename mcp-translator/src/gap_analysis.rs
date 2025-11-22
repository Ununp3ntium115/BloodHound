use anyhow::{Context, Result};
use serde::{Deserialize, Serialize};
use std::collections::{HashMap, HashSet};
use std::path::Path;

use crate::parser::{CodeParser, ExtractedFunction, Language};

/// Gap analysis result
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct GapAnalysis {
    /// Functions in source (Go)
    pub source_functions: Vec<FunctionInfo>,
    /// Functions implemented in Rust
    pub rust_functions: Vec<FunctionInfo>,
    /// Missing functions (in source but not in Rust)
    pub missing_functions: Vec<FunctionInfo>,
    /// Extra functions (in Rust but not in source)
    pub extra_functions: Vec<FunctionInfo>,
    /// Coverage percentage
    pub coverage_percent: f64,
    /// Modules analyzed
    pub modules: Vec<ModuleAnalysis>,
}

/// Function information for analysis
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq, Hash)]
pub struct FunctionInfo {
    pub name: String,
    pub module: String,
    pub file_path: String,
    pub signature: String,
}

/// Module-level analysis
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ModuleAnalysis {
    pub module_name: String,
    pub total_functions: usize,
    pub implemented: usize,
    pub missing: usize,
    pub coverage_percent: f64,
}

/// Gap analyzer
pub struct GapAnalyzer {
    parser: CodeParser,
}

impl GapAnalyzer {
    /// Create new gap analyzer
    pub fn new() -> Self {
        Self {
            parser: CodeParser::new(),
        }
    }

    /// Analyze gap between Go source and Rust implementation
    pub fn analyze(&mut self, go_source_path: &str, rust_source_path: &str) -> Result<GapAnalysis> {
        // Parse Go source
        let go_functions = self.parse_go_source(go_source_path)?;

        // Parse Rust source
        let rust_functions = self.parse_rust_source(rust_source_path)?;

        // Compare and find gaps
        let (missing, extra) = self.compare_functions(&go_functions, &rust_functions);

        // Calculate coverage
        let coverage = if go_functions.is_empty() {
            100.0
        } else {
            ((go_functions.len() - missing.len()) as f64 / go_functions.len() as f64) * 100.0
        };

        // Analyze by module
        let modules = self.analyze_modules(&go_functions, &rust_functions);

        Ok(GapAnalysis {
            source_functions: go_functions,
            rust_functions,
            missing_functions: missing,
            extra_functions: extra,
            coverage_percent: coverage,
            modules,
        })
    }

    /// Parse Go source code
    fn parse_go_source(&mut self, path: &str) -> Result<Vec<FunctionInfo>> {
        let functions = self.parser.parse_directory(path, &Language::Go, true)?;

        Ok(functions
            .iter()
            .map(|f| FunctionInfo {
                name: f.name.clone(),
                module: self.extract_module(&f.file_path),
                file_path: f.file_path.display().to_string(),
                signature: f.signature.clone(),
            })
            .collect())
    }

    /// Parse Rust source code
    fn parse_rust_source(&mut self, path: &str) -> Result<Vec<FunctionInfo>> {
        let functions = self.parser.parse_directory(path, &Language::Rust, true)?;

        Ok(functions
            .iter()
            .map(|f| FunctionInfo {
                name: f.name.clone(),
                module: self.extract_module(&f.file_path),
                file_path: f.file_path.display().to_string(),
                signature: f.signature.clone(),
            })
            .collect())
    }

    /// Compare functions and find gaps
    fn compare_functions(
        &self,
        go_funcs: &[FunctionInfo],
        rust_funcs: &[FunctionInfo],
    ) -> (Vec<FunctionInfo>, Vec<FunctionInfo>) {
        let go_set: HashSet<&str> = go_funcs.iter().map(|f| f.name.as_str()).collect();
        let rust_set: HashSet<&str> = rust_funcs.iter().map(|f| f.name.as_str()).collect();

        // Find missing (in Go but not in Rust)
        let missing: Vec<FunctionInfo> = go_funcs
            .iter()
            .filter(|f| !rust_set.contains(f.name.as_str()))
            .cloned()
            .collect();

        // Find extra (in Rust but not in Go)
        let extra: Vec<FunctionInfo> = rust_funcs
            .iter()
            .filter(|f| !go_set.contains(f.name.as_str()))
            .cloned()
            .collect();

        (missing, extra)
    }

    /// Analyze by module
    fn analyze_modules(
        &self,
        go_funcs: &[FunctionInfo],
        rust_funcs: &[FunctionInfo],
    ) -> Vec<ModuleAnalysis> {
        let mut modules: HashMap<String, (usize, usize)> = HashMap::new();

        // Count Go functions by module
        for func in go_funcs {
            let entry = modules.entry(func.module.clone()).or_insert((0, 0));
            entry.0 += 1;
        }

        // Count Rust functions by module
        let rust_set: HashSet<&str> = rust_funcs.iter().map(|f| f.name.as_str()).collect();
        for func in go_funcs {
            if rust_set.contains(func.name.as_str()) {
                let entry = modules.entry(func.module.clone()).or_insert((0, 0));
                entry.1 += 1;
            }
        }

        modules
            .into_iter()
            .map(|(name, (total, implemented))| {
                let coverage = if total == 0 {
                    100.0
                } else {
                    (implemented as f64 / total as f64) * 100.0
                };

                ModuleAnalysis {
                    module_name: name,
                    total_functions: total,
                    implemented,
                    missing: total - implemented,
                    coverage_percent: coverage,
                }
            })
            .collect()
    }

    /// Extract module name from file path
    fn extract_module(&self, path: &Path) -> String {
        path.components()
            .rev()
            .nth(1)
            .and_then(|c| c.as_os_str().to_str())
            .unwrap_or("unknown")
            .to_string()
    }
}

impl Default for GapAnalyzer {
    fn default() -> Self {
        Self::new()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_gap_analyzer() {
        let analyzer = GapAnalyzer::new();
        assert!(analyzer.parser.get_files_processed() == 0);
    }
}

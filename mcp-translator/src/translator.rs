use anyhow::{Context, Result};
use cryptex::Cryptex;
use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use std::path::PathBuf;

use crate::parser::ExtractedFunction;

/// Translator that converts extracted functions to Cryptex structure
pub struct CryptexTranslator {
    function_map: HashMap<String, String>, // name -> path_name mapping
}

impl CryptexTranslator {
    /// Create new translator
    pub fn new() -> Result<Self> {
        Ok(Self {
            function_map: HashMap::new(),
        })
    }

    /// Translate functions to Cryptex structure
    pub fn translate_functions(
        &mut self,
        functions: &[ExtractedFunction],
        cryptex_path: &str,
        root_parent: Option<String>,
    ) -> Result<Vec<String>> {
        let mut cryptex = Cryptex::new(cryptex_path)?;
        let mut created_paths = Vec::new();

        // Build function call graph to determine parent-child relationships
        let call_graph = self.build_call_graph(functions);

        // First pass: create all functions
        for func in functions {
            let parent = self.determine_parent(func, &call_graph, root_parent.as_deref());
            let path_name =
                self.create_function_in_cryptex(&mut cryptex, func, parent.as_deref())?;

            self.function_map
                .insert(func.name.clone(), path_name.clone());
            created_paths.push(path_name);
        }

        Ok(created_paths)
    }

    /// Build call graph from functions
    fn build_call_graph(&self, functions: &[ExtractedFunction]) -> HashMap<String, Vec<String>> {
        let mut graph = HashMap::new();

        for func in functions {
            graph.insert(func.name.clone(), func.calls.clone());
        }

        graph
    }

    /// Determine parent function based on call graph
    fn determine_parent(
        &self,
        func: &ExtractedFunction,
        call_graph: &HashMap<String, Vec<String>>,
        root_parent: Option<&str>,
    ) -> Option<String> {
        // If function is called by only one other function, that's the parent
        let callers: Vec<String> = call_graph
            .iter()
            .filter(|(_, calls)| calls.contains(&func.name))
            .map(|(name, _)| name.clone())
            .collect();

        if callers.len() == 1 {
            // Get the path_name of the parent
            self.function_map.get(&callers[0]).cloned()
        } else if let Some(root) = root_parent {
            Some(root.to_string())
        } else {
            None
        }
    }

    /// Create function in Cryptex structure
    fn create_function_in_cryptex(
        &self,
        cryptex: &mut Cryptex,
        func: &ExtractedFunction,
        parent: Option<&str>,
    ) -> Result<String> {
        // Generate pseudocode from function signature and doc comment
        let pseudocode = self.generate_pseudocode(func);

        // Add function to cryptex
        let node = cryptex.add_function(
            parent.map(|s| s.to_string()),
            func.name.clone(),
            func.body.clone(),
            pseudocode,
        )?;

        Ok(node.path_name)
    }

    /// Generate pseudocode description from function
    fn generate_pseudocode(&self, func: &ExtractedFunction) -> String {
        let mut pseudo = String::new();

        // Add doc comment if available
        if let Some(doc) = &func.doc_comment {
            pseudo.push_str(doc);
            pseudo.push_str("\n\n");
        }

        // Generate from signature
        pseudo.push_str(&format!("Function: {}\n", func.name));
        pseudo.push_str(&format!("Signature: {}\n", func.signature));

        if !func.calls.is_empty() {
            pseudo.push_str(&format!("Calls: {}\n", func.calls.join(", ")));
        }

        // Add file location
        pseudo.push_str(&format!(
            "Source: {}:{}\n",
            func.file_path.display(),
            func.line_number
        ));

        pseudo
    }
}

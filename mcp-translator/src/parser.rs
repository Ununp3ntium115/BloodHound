use anyhow::{Context, Result};
use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use std::path::{Path, PathBuf};

/// Supported programming languages
#[derive(Debug, Clone, Copy)]
pub enum Language {
    Go,
    Rust,
    JavaScript,
    Python,
}

impl Language {
    pub fn from_str(s: &str) -> Result<Self> {
        match s.to_lowercase().as_str() {
            "go" => Ok(Self::Go),
            "rust" => Ok(Self::Rust),
            "javascript" | "js" => Ok(Self::JavaScript),
            "python" | "py" => Ok(Self::Python),
            _ => anyhow::bail!("Unsupported language: {}", s),
        }
    }

    pub fn file_extensions(&self) -> Vec<&'static str> {
        match self {
            Self::Go => vec!["go"],
            Self::Rust => vec!["rs"],
            Self::JavaScript => vec!["js", "jsx", "ts", "tsx"],
            Self::Python => vec!["py"],
        }
    }
}

/// Extracted function from source code
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ExtractedFunction {
    pub name: String,
    pub signature: String,
    pub body: String,
    pub file_path: PathBuf,
    pub line_number: usize,
    pub calls: Vec<String>,     // Functions this function calls
    pub called_by: Vec<String>, // Functions that call this function
    pub package: Option<String>,
    pub doc_comment: Option<String>,
}

/// Codebase analysis result
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CodebaseAnalysis {
    pub total_files: usize,
    pub total_functions: usize,
    pub relationships: HashMap<String, Vec<String>>,
    pub packages: Vec<String>,
}

/// Code parser for extracting functions from source code
pub struct CodeParser {
    files_processed: usize,
}

impl CodeParser {
    /// Create new code parser
    pub fn new() -> Self {
        Self { files_processed: 0 }
    }

    /// Parse a single file
    pub fn parse_file<P: AsRef<Path>>(
        &mut self,
        file_path: P,
        language: &Language,
    ) -> Result<Vec<ExtractedFunction>> {
        let file_path = file_path.as_ref();
        let content = std::fs::read_to_string(file_path)
            .with_context(|| format!("Failed to read file: {:?}", file_path))?;

        self.files_processed += 1;

        match language {
            Language::Go => self.parse_go(&content, file_path),
            Language::Rust => self.parse_rust(&content, file_path),
            Language::JavaScript => self.parse_javascript(&content, file_path),
            Language::Python => self.parse_python(&content, file_path),
        }
    }

    /// Parse a directory
    pub fn parse_directory<P: AsRef<Path>>(
        &mut self,
        dir_path: P,
        language: &Language,
        recursive: bool,
    ) -> Result<Vec<ExtractedFunction>> {
        let dir_path = dir_path.as_ref();
        let mut all_functions = Vec::new();
        let extensions = language.file_extensions();
        let mut files_to_parse: Vec<PathBuf> = Vec::new();

        self.walk_directory(dir_path, &extensions, recursive, &mut |file_path| {
            files_to_parse.push(file_path.to_path_buf());
        })?;

        for file_path in files_to_parse {
            if let Ok(mut functions) = self.parse_file(&file_path, language) {
                all_functions.append(&mut functions);
            }
        }

        Ok(all_functions)
    }

    /// Analyze codebase structure
    pub fn analyze_codebase<P: AsRef<Path>>(
        &mut self,
        dir_path: P,
        language: &Language,
    ) -> Result<CodebaseAnalysis> {
        let functions = self.parse_directory(dir_path, language, true)?;

        let mut relationships = HashMap::new();
        let mut packages = std::collections::HashSet::new();

        for func in &functions {
            if let Some(pkg) = &func.package {
                packages.insert(pkg.clone());
            }

            relationships.insert(func.name.clone(), func.calls.clone());
        }

        Ok(CodebaseAnalysis {
            total_files: self.files_processed,
            total_functions: functions.len(),
            relationships,
            packages: packages.into_iter().collect(),
        })
    }

    /// Get number of files processed
    pub fn get_files_processed(&self) -> usize {
        self.files_processed
    }

    /// Parse Go code
    fn parse_go(&self, content: &str, file_path: &Path) -> Result<Vec<ExtractedFunction>> {
        // Simple regex-based parsing (in production, use tree-sitter-go)
        let mut functions = Vec::new();
        let lines: Vec<&str> = content.lines().collect();

        for (line_num, line) in lines.iter().enumerate() {
            // Match function definitions: func FunctionName(...) ...
            if line.trim().starts_with("func ") {
                if let Some(func) = self.extract_go_function(content, line_num, file_path)? {
                    functions.push(func);
                }
            }
        }

        Ok(functions)
    }

    /// Parse Rust code
    fn parse_rust(&self, content: &str, file_path: &Path) -> Result<Vec<ExtractedFunction>> {
        let mut functions = Vec::new();
        let lines: Vec<&str> = content.lines().collect();

        for (line_num, line) in lines.iter().enumerate() {
            // Match function definitions: fn function_name(...) ...
            if line.trim().starts_with("fn ") || line.trim().starts_with("pub fn ") {
                if let Some(func) = self.extract_rust_function(content, line_num, file_path)? {
                    functions.push(func);
                }
            }
        }

        Ok(functions)
    }

    /// Parse JavaScript/TypeScript code
    fn parse_javascript(&self, content: &str, file_path: &Path) -> Result<Vec<ExtractedFunction>> {
        let mut functions = Vec::new();
        let lines: Vec<&str> = content.lines().collect();

        for (line_num, line) in lines.iter().enumerate() {
            // Match various function definitions
            if line.contains("function ")
                || line.contains("=>")
                || line.contains("const ") && line.contains("=")
            {
                if let Some(func) = self.extract_js_function(content, line_num, file_path)? {
                    functions.push(func);
                }
            }
        }

        Ok(functions)
    }

    /// Parse Python code
    fn parse_python(&self, content: &str, file_path: &Path) -> Result<Vec<ExtractedFunction>> {
        let mut functions = Vec::new();
        let lines: Vec<&str> = content.lines().collect();

        for (line_num, line) in lines.iter().enumerate() {
            // Match function definitions: def function_name(...):
            if line.trim().starts_with("def ") {
                if let Some(func) = self.extract_python_function(content, line_num, file_path)? {
                    functions.push(func);
                }
            }
        }

        Ok(functions)
    }

    /// Extract Go function details
    fn extract_go_function(
        &self,
        content: &str,
        line_num: usize,
        file_path: &Path,
    ) -> Result<Option<ExtractedFunction>> {
        let lines: Vec<&str> = content.lines().collect();
        if line_num >= lines.len() {
            return Ok(None);
        }

        let line = lines[line_num];

        // Extract function name and signature
        if let Some(cap) = regex::Regex::new(r"func\s+(\w+)\s*\([^)]*\)")
            .ok()
            .and_then(|re| re.captures(line))
        {
            let name = cap.get(1).unwrap().as_str().to_string();
            let signature = line.trim().to_string();

            // Extract body (simplified - find next closing brace)
            let mut body = String::new();
            let mut brace_count = 0;
            let mut in_function = false;

            for (i, l) in lines.iter().enumerate().skip(line_num) {
                if i == line_num {
                    in_function = true;
                }
                if in_function {
                    body.push_str(l);
                    body.push('\n');
                    brace_count += l.matches('{').count() as i32;
                    brace_count -= l.matches('}').count() as i32;
                    if brace_count == 0 && i > line_num {
                        break;
                    }
                }
            }

            Ok(Some(ExtractedFunction {
                name,
                signature,
                body,
                file_path: file_path.to_path_buf(),
                line_number: line_num + 1,
                calls: Vec::new(), // TODO: Extract function calls
                called_by: Vec::new(),
                package: None,     // TODO: Extract package
                doc_comment: None, // TODO: Extract doc comments
            }))
        } else {
            Ok(None)
        }
    }

    /// Extract Rust function details
    fn extract_rust_function(
        &self,
        content: &str,
        line_num: usize,
        file_path: &Path,
    ) -> Result<Option<ExtractedFunction>> {
        let lines: Vec<&str> = content.lines().collect();
        if line_num >= lines.len() {
            return Ok(None);
        }

        let line = lines[line_num];

        // Extract function name and signature
        if let Some(cap) = regex::Regex::new(r"fn\s+(\w+)\s*\([^)]*\)")
            .ok()
            .and_then(|re| re.captures(line))
        {
            let name = cap.get(1).unwrap().as_str().to_string();
            let signature = line.trim().to_string();

            // Extract body
            let mut body = String::new();
            let mut brace_count = 0;
            let mut in_function = false;

            for (i, l) in lines.iter().enumerate().skip(line_num) {
                if i == line_num {
                    in_function = true;
                }
                if in_function {
                    body.push_str(l);
                    body.push('\n');
                    brace_count += l.matches('{').count() as i32;
                    brace_count -= l.matches('}').count() as i32;
                    if brace_count == 0 && i > line_num {
                        break;
                    }
                }
            }

            Ok(Some(ExtractedFunction {
                name,
                signature,
                body,
                file_path: file_path.to_path_buf(),
                line_number: line_num + 1,
                calls: Vec::new(),
                called_by: Vec::new(),
                package: None,
                doc_comment: None,
            }))
        } else {
            Ok(None)
        }
    }

    /// Extract JavaScript function details
    fn extract_js_function(
        &self,
        _content: &str,
        _line_num: usize,
        _file_path: &Path,
    ) -> Result<Option<ExtractedFunction>> {
        // Simplified - would use tree-sitter in production
        Ok(None)
    }

    /// Extract Python function details
    fn extract_python_function(
        &self,
        content: &str,
        line_num: usize,
        file_path: &Path,
    ) -> Result<Option<ExtractedFunction>> {
        let lines: Vec<&str> = content.lines().collect();
        if line_num >= lines.len() {
            return Ok(None);
        }

        let line = lines[line_num];

        if let Some(cap) = regex::Regex::new(r"def\s+(\w+)\s*\([^)]*\)")
            .ok()
            .and_then(|re| re.captures(line))
        {
            let name = cap.get(1).unwrap().as_str().to_string();
            let signature = line.trim().to_string();

            // Extract body (until next def or end of indentation)
            let mut body = String::new();
            let base_indent = line.len() - line.trim_start().len();

            for l in lines.iter().skip(line_num) {
                if l.trim().is_empty() {
                    body.push_str(l);
                    body.push('\n');
                    continue;
                }

                let indent = l.len() - l.trim_start().len();
                if indent <= base_indent && l.trim().starts_with("def ") && *l != line {
                    break;
                }

                body.push_str(l);
                body.push('\n');
            }

            Ok(Some(ExtractedFunction {
                name,
                signature,
                body,
                file_path: file_path.to_path_buf(),
                line_number: line_num + 1,
                calls: Vec::new(),
                called_by: Vec::new(),
                package: None,
                doc_comment: None,
            }))
        } else {
            Ok(None)
        }
    }

    /// Walk directory recursively
    fn walk_directory<F>(
        &self,
        dir: &Path,
        extensions: &[&str],
        recursive: bool,
        callback: &mut F,
    ) -> Result<()>
    where
        F: FnMut(&Path),
    {
        for entry in std::fs::read_dir(dir)? {
            let entry = entry?;
            let path = entry.path();

            if path.is_file() {
                if let Some(ext) = path.extension().and_then(|e| e.to_str()) {
                    let ext_lower = ext.to_lowercase();
                    if extensions.iter().any(|candidate| candidate.eq(&ext_lower)) {
                        callback(&path);
                    }
                }
            } else if path.is_dir() && recursive {
                self.walk_directory(&path, extensions, recursive, callback)?;
            }
        }

        Ok(())
    }
}

impl Default for CodeParser {
    fn default() -> Self {
        Self::new()
    }
}

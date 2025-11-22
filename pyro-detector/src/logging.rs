use std::fmt;
use std::fs::{File, OpenOptions};
use std::io::{self, Write};
use std::path::{Path, PathBuf};
use std::sync::{Arc, Mutex};
use chrono::Utc;
use serde_json::json;

/// Log levels
#[derive(Debug, Clone, Copy, PartialEq, Eq, PartialOrd, Ord)]
pub enum LogLevel {
    Error = 0,
    Warn = 1,
    Info = 2,
    Debug = 3,
    Trace = 4,
}

impl fmt::Display for LogLevel {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            LogLevel::Error => write!(f, "ERROR"),
            LogLevel::Warn => write!(f, "WARN"),
            LogLevel::Info => write!(f, "INFO"),
            LogLevel::Debug => write!(f, "DEBUG"),
            LogLevel::Trace => write!(f, "TRACE"),
        }
    }
}

/// Structured log entry
#[derive(Debug, Clone)]
pub struct LogEntry {
    pub timestamp: chrono::DateTime<Utc>,
    pub level: LogLevel,
    pub component: String,
    pub message: String,
    pub fields: serde_json::Value,
    pub error: Option<String>,
}

/// Comprehensive logger for PYRO Detector with file output and rotation
pub struct Logger {
    level: LogLevel,
    log_dir: PathBuf,
    file_logger: Arc<Mutex<Option<File>>>,
    max_file_size: u64,
    max_files: usize,
    enable_console: bool,
    enable_json: bool,
}

impl Logger {
    /// Create new logger with file output
    pub fn new(level: LogLevel, log_dir: impl AsRef<Path>) -> io::Result<Self> {
        let log_dir = log_dir.as_ref().to_path_buf();
        std::fs::create_dir_all(&log_dir)?;

        let log_file = log_dir.join(format!("pyro-detector-{}.log", Utc::now().format("%Y%m%d")));
        let file = OpenOptions::new()
            .create(true)
            .append(true)
            .open(&log_file)?;

        Ok(Self {
            level,
            log_dir,
            file_logger: Arc::new(Mutex::new(Some(file))),
            max_file_size: 10 * 1024 * 1024, // 10MB
            max_files: 10,
            enable_console: true,
            enable_json: false,
        })
    }

    /// Create logger with JSON output
    pub fn with_json(mut self, enable: bool) -> Self {
        self.enable_json = enable;
        self
    }

    /// Set max file size in bytes
    pub fn with_max_file_size(mut self, size: u64) -> Self {
        self.max_file_size = size;
        self
    }

    /// Set max number of log files to keep
    pub fn with_max_files(mut self, max: usize) -> Self {
        self.max_files = max;
        self
    }

    /// Rotate log file if needed
    fn rotate_if_needed(&self) -> io::Result<()> {
        let mut file_guard = self.file_logger.lock().unwrap();
        if let Some(ref file) = *file_guard {
            if let Ok(metadata) = file.metadata() {
                if metadata.len() >= self.max_file_size {
                    // Close current file
                    drop(file_guard);
                    
                    // Rotate: move current to .1, .1 to .2, etc.
                    let base_name = format!("pyro-detector-{}.log", Utc::now().format("%Y%m%d"));
                    for i in (1..self.max_files).rev() {
                        let old = self.log_dir.join(format!("{}.{}", base_name, i));
                        let new = self.log_dir.join(format!("{}.{}", base_name, i + 1));
                        if old.exists() {
                            let _ = std::fs::rename(&old, &new);
                        }
                    }
                    
                    // Create new file
                    let new_file = self.log_dir.join(format!("{}.1", base_name));
                    if self.log_dir.join(&base_name).exists() {
                        std::fs::rename(self.log_dir.join(&base_name), &new_file)?;
                    }
                    
                    let file = OpenOptions::new()
                        .create(true)
                        .append(true)
                        .open(self.log_dir.join(&base_name))?;
                    *file_guard = Some(file);
                }
            }
        }
        Ok(())
    }

    /// Write log entry
    fn write_entry(&self, entry: &LogEntry) -> io::Result<()> {
        if entry.level as u8 > self.level as u8 {
            return Ok(());
        }

        self.rotate_if_needed()?;

        let timestamp = entry.timestamp.format("%Y-%m-%d %H:%M:%S%.3f UTC");
        let log_line = if self.enable_json {
            let json_entry = json!({
                "timestamp": timestamp.to_string(),
                "level": entry.level.to_string(),
                "component": entry.component,
                "message": entry.message,
                "fields": entry.fields,
                "error": entry.error,
            });
            format!("{}\n", serde_json::to_string(&json_entry)?)
        } else {
            let fields_str = if entry.fields.is_object() && entry.fields.as_object().unwrap().len() > 0 {
                format!(" | {}", serde_json::to_string(&entry.fields)?)
            } else {
                String::new()
            };
            let error_str = entry.error.as_ref()
                .map(|e| format!(" | ERROR: {}", e))
                .unwrap_or_default();
            format!("[{}] [{}] [{}] {}{}{}\n", 
                timestamp, entry.level, entry.component, entry.message, fields_str, error_str)
        };

        // Write to file
        if let Ok(mut file_guard) = self.file_logger.lock() {
            if let Some(ref mut file) = *file_guard {
                file.write_all(log_line.as_bytes())?;
                file.flush()?;
            }
        }

        // Write to console
        if self.enable_console {
            eprintln!("{}", log_line.trim_end());
        }

        Ok(())
    }

    /// Log with component and fields
    pub fn log_with_fields(&self, level: LogLevel, component: &str, message: &str, fields: serde_json::Value, error: Option<&dyn std::error::Error>) {
        let entry = LogEntry {
            timestamp: Utc::now(),
            level,
            component: component.to_string(),
            message: message.to_string(),
            fields,
            error: error.map(|e| format!("{}", e)),
        };
        let _ = self.write_entry(&entry);
    }

    /// Log error
    pub fn error(&self, component: &str, message: &str) {
        self.log_with_fields(LogLevel::Error, component, message, json!({}), None);
    }

    /// Log error with fields
    pub fn error_with_fields(&self, component: &str, message: &str, fields: serde_json::Value) {
        self.log_with_fields(LogLevel::Error, component, message, fields, None);
    }

    /// Log error with error object
    pub fn error_with_error(&self, component: &str, message: &str, error: &dyn std::error::Error) {
        self.log_with_fields(LogLevel::Error, component, message, json!({}), Some(error));
    }

    /// Log warning
    pub fn warn(&self, component: &str, message: &str) {
        self.log_with_fields(LogLevel::Warn, component, message, json!({}), None);
    }

    /// Log warning with fields
    pub fn warn_with_fields(&self, component: &str, message: &str, fields: serde_json::Value) {
        self.log_with_fields(LogLevel::Warn, component, message, fields, None);
    }

    /// Log info
    pub fn info(&self, component: &str, message: &str) {
        self.log_with_fields(LogLevel::Info, component, message, json!({}), None);
    }

    /// Log info with fields
    pub fn info_with_fields(&self, component: &str, message: &str, fields: serde_json::Value) {
        self.log_with_fields(LogLevel::Info, component, message, fields, None);
    }

    /// Log debug
    pub fn debug(&self, component: &str, message: &str) {
        self.log_with_fields(LogLevel::Debug, component, message, json!({}), None);
    }

    /// Log debug with fields
    pub fn debug_with_fields(&self, component: &str, message: &str, fields: serde_json::Value) {
        self.log_with_fields(LogLevel::Debug, component, message, fields, None);
    }

    /// Log trace
    pub fn trace(&self, component: &str, message: &str) {
        self.log_with_fields(LogLevel::Trace, component, message, json!({}), None);
    }

    /// Log trace with fields
    pub fn trace_with_fields(&self, component: &str, message: &str, fields: serde_json::Value) {
        self.log_with_fields(LogLevel::Trace, component, message, fields, None);
    }

    /// Log MCP request
    pub fn log_mcp_request(&self, method: &str, params: &serde_json::Value, request_id: u64) {
        self.info_with_fields("MCP", "Request received", json!({
            "method": method,
            "request_id": request_id,
            "params": params,
        }));
    }

    /// Log MCP response
    pub fn log_mcp_response(&self, method: &str, request_id: u64, success: bool, duration_ms: u64) {
        self.info_with_fields("MCP", "Response sent", json!({
            "method": method,
            "request_id": request_id,
            "success": success,
            "duration_ms": duration_ms,
        }));
    }

    /// Log API call
    pub fn log_api_call(&self, method: &str, url: &str, status_code: Option<u16>, duration_ms: u64) {
        let level = if status_code.map(|c| c >= 400).unwrap_or(false) {
            LogLevel::Error
        } else {
            LogLevel::Info
        };
        self.log_with_fields(level, "API", "HTTP request", json!({
            "method": method,
            "url": url,
            "status_code": status_code,
            "duration_ms": duration_ms,
        }), None);
    }
}

impl Default for Logger {
    fn default() -> Self {
        Self::new(LogLevel::Info, "./logs").unwrap_or_else(|_| {
            // Fallback to stderr-only logging if file creation fails
            panic!("Failed to create logger")
        })
    }
}

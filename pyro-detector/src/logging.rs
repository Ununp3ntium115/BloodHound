use std::fmt;

/// Log levels
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum LogLevel {
    Error,
    Warn,
    Info,
    Debug,
    Trace,
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

/// Simple logger for PYRO Detector
pub struct Logger {
    level: LogLevel,
    enable_timestamps: bool,
}

impl Logger {
    /// Create new logger
    pub fn new(level: LogLevel) -> Self {
        Self {
            level,
            enable_timestamps: true,
        }
    }

    /// Log a message
    pub fn log(&self, level: LogLevel, message: &str) {
        if level as u8 <= self.level as u8 {
            let timestamp = if self.enable_timestamps {
                chrono::Utc::now().format("%Y-%m-%d %H:%M:%S%.3f UTC").to_string()
            } else {
                String::new()
            };

            let prefix = if self.enable_timestamps {
                format!("[{}] [{}] ", timestamp, level)
            } else {
                format!("[{}] ", level)
            };

            eprintln!("{}{}", prefix, message);
        }
    }

    /// Log error
    pub fn error(&self, message: &str) {
        self.log(LogLevel::Error, message);
    }

    /// Log warning
    pub fn warn(&self, message: &str) {
        self.log(LogLevel::Warn, message);
    }

    /// Log info
    pub fn info(&self, message: &str) {
        self.log(LogLevel::Info, message);
    }

    /// Log debug
    pub fn debug(&self, message: &str) {
        self.log(LogLevel::Debug, message);
    }

    /// Log trace
    pub fn trace(&self, message: &str) {
        self.log(LogLevel::Trace, message);
    }
}

impl Default for Logger {
    fn default() -> Self {
        Self::new(LogLevel::Info)
    }
}


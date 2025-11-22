// Authentication module for BloodSniffer
// Translated from cmd/api/src/api/auth.go

pub mod crypto;
pub mod handlers;
pub mod session;

// Re-export commonly used items
pub use crypto::PasswordHasher;
pub use session::{generate_jwt_token, validate_jwt_token, Session};

// Database module for BloodSniffer
// Translated from cmd/api/src/database

pub mod migrations;
pub mod models;
pub mod redb_store;

pub use models::{AuthSecret, Installation, Role, User, UserSession};
pub use redb_store::RedbDatabase;

use anyhow::Result;

/// Database trait for BloodSniffer
pub trait Database: Send + Sync {
    /// Run database migrations
    fn migrate(&self) -> Result<()>;

    /// Check if installation exists
    fn has_installation(&self) -> Result<bool>;

    /// Create installation record
    fn create_installation(&self) -> Result<Installation>;

    /// Get all roles
    fn get_all_roles(&self) -> Result<Vec<Role>>;

    /// Lookup user by principal name
    fn lookup_user(&self, principal_name: &str) -> Result<Option<User>>;

    /// Delete user
    fn delete_user(&self, user: &User) -> Result<()>;

    /// Initialize secret auth for user
    fn initialize_secret_auth(&self, user: &User, secret: &AuthSecret) -> Result<User>;

    /// Create user session
    fn create_session(&self, session: &UserSession) -> Result<()>;

    /// Get session by token
    fn get_session(&self, token: &str) -> Result<Option<UserSession>>;

    /// Get user session by session ID
    fn get_user_session(&self, session_id: &uuid::Uuid) -> Result<Option<UserSession>>;

    /// End user session (delete by session ID)
    fn end_user_session(&self, session_id: &uuid::Uuid) -> Result<()>;

    /// Delete session
    fn delete_session(&self, session_id: &uuid::Uuid) -> Result<()>;
}

// Database models for BloodSniffer

use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use uuid::Uuid;

/// User model
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct User {
    pub id: Uuid,
    pub principal_name: String,
    pub email_address: Option<String>,
    pub first_name: Option<String>,
    pub last_name: Option<String>,
    pub all_environments: bool,
    pub roles: Vec<Role>,
    pub auth_secret: Option<AuthSecret>,
}

/// Role model
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
pub struct Role {
    pub id: Uuid,
    pub name: String,
    pub description: Option<String>,
}

impl Role {
    /// Administrator role name
    pub const ADMINISTRATOR: &'static str = "Administrator";

    /// Find role by name
    pub fn find_by_name<'a>(roles: &'a [Role], name: &str) -> Option<&'a Role> {
        roles.iter().find(|r| r.name == name)
    }
}

/// Authentication secret
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AuthSecret {
    pub digest: String,
    pub digest_method: String,
    pub expires_at: Option<DateTime<Utc>>,
}

/// Installation record
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Installation {
    pub id: Uuid,
    pub created_at: DateTime<Utc>,
}

/// User session
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct UserSession {
    pub id: Uuid,
    pub user_id: Uuid,
    pub token: String,
    pub created_at: DateTime<Utc>,
    pub expires_at: DateTime<Utc>,
}

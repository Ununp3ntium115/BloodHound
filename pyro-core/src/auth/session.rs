// Session management for BloodSniffer

use anyhow::Result;
use chrono::{DateTime, Duration, Utc};
use jsonwebtoken::{decode, encode, DecodingKey, EncodingKey, Header, Validation};
use serde::{Deserialize, Serialize};
use uuid::Uuid;

use crate::database::models::User;

/// Claims for JWT
#[derive(Debug, Serialize, Deserialize)]
pub struct Claims {
    pub sub: String, // User ID
    pub exp: i64,    // Expiration time
    pub iat: i64,    // Issued at
    pub jti: String, // JWT ID (session ID)
}

/// Session information
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Session {
    pub id: Uuid,
    pub user_id: Uuid,
    pub created_at: DateTime<Utc>,
    pub expires_at: DateTime<Utc>,
}

impl Session {
    /// Create a new session
    pub fn new(user: &User, duration_hours: i64) -> Self {
        let now = Utc::now();
        let expires_at = now + Duration::hours(duration_hours);
        Self {
            id: Uuid::new_v4(),
            user_id: user.id,
            created_at: now,
            expires_at,
        }
    }
}

/// Generate a JWT token for a user
pub fn generate_jwt_token(
    user: &User,
    session_id: &Uuid,
    secret: &[u8],
    duration_hours: i64,
) -> Result<String> {
    let now = Utc::now();
    let expiration = (now + Duration::hours(duration_hours)).timestamp();

    let claims = Claims {
        sub: user.id.to_string(),
        exp: expiration,
        iat: now.timestamp(),
        jti: session_id.to_string(),
    };

    encode(
        &Header::default(),
        &claims,
        &EncodingKey::from_secret(secret),
    )
    .map_err(|e| anyhow::anyhow!("Failed to encode JWT: {}", e))
}

/// Validate a JWT token
pub fn validate_jwt_token(token: &str, secret: &[u8]) -> Result<Claims> {
    decode::<Claims>(
        token,
        &DecodingKey::from_secret(secret),
        &Validation::default(),
    )
    .map(|data| data.claims)
    .map_err(|e| anyhow::anyhow!("Failed to validate JWT: {}", e))
}

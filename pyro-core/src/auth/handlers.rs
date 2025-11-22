// Authentication API handlers
// Translated from cmd/api/src/api/auth.go

use axum::{
    extract::State,
    http::{HeaderMap, StatusCode},
    response::Json,
};
use serde::{Deserialize, Serialize};
use serde_json::json;

use crate::api::state::AppState;
use crate::auth::{
    crypto::PasswordHasher,
    session::{generate_jwt_token, Session},
};
use crate::database::{Database, RedbDatabase};

/// Login request
#[derive(Debug, Deserialize)]
pub struct LoginRequest {
    pub username: String,
    pub password: String,
}

/// Login response
#[derive(Debug, Serialize)]
pub struct LoginResponse {
    pub token: String,
    pub user: UserInfo,
}

/// User information
#[derive(Debug, Serialize)]
pub struct UserInfo {
    pub id: String,
    pub principal_name: String,
    pub email_address: Option<String>,
    pub first_name: Option<String>,
    pub last_name: Option<String>,
}

/// Login with secret (dictionary: api_login_with_secret)
/// Pseudocode: Authenticate user with username and password, return session token
pub async fn api_login_with_secret(
    State(state): State<AppState>,
    Json(req): Json<LoginRequest>,
) -> Result<Json<LoginResponse>, StatusCode> {
    // Open database
    let db = RedbDatabase::open(&state.config.database.path)
        .map_err(|_| StatusCode::INTERNAL_SERVER_ERROR)?;

    // Lookup user
    let user = db
        .lookup_user(&req.username)
        .map_err(|_| StatusCode::INTERNAL_SERVER_ERROR)?
        .ok_or(StatusCode::UNAUTHORIZED)?;

    // Verify password hash from database
    let hasher = PasswordHasher::new();

    // Get user's auth secret
    let auth_secret = user.auth_secret.as_ref().ok_or(StatusCode::UNAUTHORIZED)?;

    // Verify password
    let is_valid = hasher
        .verify_password(&req.password, &auth_secret.digest)
        .map_err(|_| StatusCode::INTERNAL_SERVER_ERROR)?;

    if !is_valid {
        return Err(StatusCode::UNAUTHORIZED);
    }

    // Create session
    let session_duration = state.config.auth.session_duration_hours;
    let session = Session::new(&user, session_duration);

    // Generate JWT token with session ID
    let token = generate_jwt_token(
        &user,
        &session.id,
        state.config.auth.jwt_secret.as_bytes(),
        session_duration,
    )
    .map_err(|_| StatusCode::INTERNAL_SERVER_ERROR)?;

    // Store session in database
    let user_session = crate::database::models::UserSession {
        id: session.id,
        user_id: session.user_id,
        token: token.clone(),
        created_at: session.created_at,
        expires_at: session.expires_at,
    };

    db.create_session(&user_session)
        .map_err(|_| StatusCode::INTERNAL_SERVER_ERROR)?;

    Ok(Json(LoginResponse {
        token,
        user: UserInfo {
            id: user.id.to_string(),
            principal_name: user.principal_name,
            email_address: user.email_address,
            first_name: user.first_name,
            last_name: user.last_name,
        },
    }))
}

/// Logout (dictionary: api_logout)
/// Pseudocode: Invalidate user session
pub async fn api_logout(
    State(state): State<AppState>,
    headers: HeaderMap,
) -> Result<Json<serde_json::Value>, StatusCode> {
    // Get token from Authorization header
    let token = headers
        .get("Authorization")
        .and_then(|h| h.to_str().ok())
        .and_then(|s| s.strip_prefix("Bearer "))
        .ok_or(StatusCode::UNAUTHORIZED)?;

    // Open database
    let db = RedbDatabase::open(&state.config.database.path)
        .map_err(|_| StatusCode::INTERNAL_SERVER_ERROR)?;

    // Get session to find ID
    if let Some(session) = db
        .get_session(token)
        .map_err(|_| StatusCode::INTERNAL_SERVER_ERROR)?
    {
        // Delete session
        db.delete_session(&session.id)
            .map_err(|_| StatusCode::INTERNAL_SERVER_ERROR)?;
    }

    Ok(Json(json!({
        "message": "Logged out successfully"
    })))
}

/// Validate session (dictionary: api_validate_session)
/// Pseudocode: Check if session token is valid
pub async fn api_validate_session(
    State(state): State<AppState>,
    headers: HeaderMap,
) -> Result<Json<serde_json::Value>, StatusCode> {
    // Get token from Authorization header
    let token = headers
        .get("Authorization")
        .and_then(|h| h.to_str().ok())
        .and_then(|s| s.strip_prefix("Bearer "))
        .ok_or(StatusCode::UNAUTHORIZED)?;

    // Open database
    let db = RedbDatabase::open(&state.config.database.path)
        .map_err(|_| StatusCode::INTERNAL_SERVER_ERROR)?;

    // Get session
    let session = db
        .get_session(token)
        .map_err(|_| StatusCode::INTERNAL_SERVER_ERROR)?
        .ok_or(StatusCode::UNAUTHORIZED)?;

    // Check if expired
    if session.expires_at < chrono::Utc::now() {
        return Ok(Json(json!({
            "valid": false,
            "reason": "expired"
        })));
    }

    Ok(Json(json!({
        "valid": true,
        "user_id": session.user_id.to_string()
    })))
}

// Authentication middleware for BloodSniffer
// Translated from cmd/api/src/api/middleware/auth.go

use crate::api::state::AppState;
use crate::auth::validate_jwt_token;
use crate::database::{Database, RedbDatabase};
use axum::{
    extract::Request,
    http::{header, HeaderMap, StatusCode},
    middleware::Next,
    response::Response,
};

/// Authentication context extracted from request
#[derive(Debug, Clone)]
pub struct AuthContext {
    pub user_id: uuid::Uuid,
    pub authenticated: bool,
}

impl AuthContext {
    pub fn authenticated(user_id: uuid::Uuid) -> Self {
        Self {
            user_id,
            authenticated: true,
        }
    }

    pub fn unauthenticated() -> Self {
        Self {
            user_id: uuid::Uuid::nil(),
            authenticated: false,
        }
    }

    pub fn is_authenticated(&self) -> bool {
        self.authenticated
    }
}

/// Extract authentication token from Authorization header
fn extract_token_from_headers(headers: &HeaderMap) -> Option<String> {
    headers
        .get("Authorization")
        .and_then(|h| h.to_str().ok())
        .and_then(|s| s.strip_prefix("Bearer "))
        .map(|s| s.to_string())
}

/// Extract authentication token from cookies
fn extract_token_from_cookies(headers: &HeaderMap) -> Option<String> {
    headers
        .get(header::COOKIE)
        .and_then(|value| value.to_str().ok())
        .and_then(|cookie_header| {
            cookie_header
                .split(';')
                .map(|cookie| cookie.trim())
                .find_map(|cookie| {
                    cookie.split_once('=').and_then(|(name, value)| {
                        (name == "session_token").then(|| value.to_string())
                    })
                })
        })
}

/// Authentication middleware (dictionary: auth_middleware)
/// Pseudocode: Validate JWT token from Authorization header or cookie, attach auth context to request
pub async fn auth_middleware(mut request: Request, next: Next) -> Result<Response, StatusCode> {
    let state = request
        .extensions()
        .get::<AppState>()
        .cloned()
        .ok_or(StatusCode::INTERNAL_SERVER_ERROR)?;
    let headers = request.headers().clone();

    // Try to extract token from header first, then cookie
    let token =
        extract_token_from_headers(&headers).or_else(|| extract_token_from_cookies(&headers));

    let auth_ctx = if let Some(token_str) = token {
        // Validate JWT token
        match validate_jwt_token(&token_str, state.config.auth.jwt_secret.as_bytes()) {
            Ok(claims) => {
                // Verify session exists in database
                let db = RedbDatabase::open(&state.config.database.path)
                    .map_err(|_| StatusCode::INTERNAL_SERVER_ERROR)?;

                // Extract session ID from JWT claims (jti field)
                if let Ok(session_id) = uuid::Uuid::parse_str(&claims.jti) {
                    if let Ok(Some(session)) = db.get_user_session(&session_id) {
                        // Check if session is expired
                        if session.expires_at < chrono::Utc::now() {
                            // Session expired, delete it
                            let _ = db.end_user_session(&session_id);
                            AuthContext::unauthenticated()
                        } else {
                            // Valid session - extract user ID from claims
                            if let Ok(user_id) = uuid::Uuid::parse_str(&claims.sub) {
                                AuthContext::authenticated(user_id)
                            } else {
                                AuthContext::unauthenticated()
                            }
                        }
                    } else {
                        AuthContext::unauthenticated()
                    }
                } else {
                    AuthContext::unauthenticated()
                }
            }
            Err(_) => AuthContext::unauthenticated(),
        }
    } else {
        AuthContext::unauthenticated()
    };

    // Attach auth context to request extensions
    request.extensions_mut().insert(auth_ctx.clone());

    // Continue to next middleware/handler
    Ok(next.run(request).await)
}

/// Require authentication middleware (dictionary: require_auth_middleware)
/// Pseudocode: Ensure request has valid authentication, return 401 if not
pub async fn require_auth_middleware(request: Request, next: Next) -> Result<Response, StatusCode> {
    let is_authenticated = request
        .extensions()
        .get::<AuthContext>()
        .map(|ctx| ctx.is_authenticated())
        .unwrap_or(false);

    if !is_authenticated {
        return Err(StatusCode::UNAUTHORIZED);
    }

    Ok(next.run(request).await)
}

/// Extract auth context from request extensions
pub fn get_auth_context(request: &Request) -> Option<AuthContext> {
    request.extensions().get::<AuthContext>().cloned()
}

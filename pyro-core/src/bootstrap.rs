// Bootstrap module - Server initialization
// Translated from cmd/api/src/bootstrap/server.go

use anyhow::{Context, Result};
use tokio::signal;

use crate::api::state::AppState;
use crate::auth::crypto::PasswordHasher;
use crate::config::Config;
use crate::database::{
    models::{AuthSecret, Role, User},
    Database, RedbDatabase,
};
use chrono::Utc;

/// Initialize BloodSniffer server (dictionary: bloodsniffer_initialize)
/// Pseudocode: Start the autonomous system, load configuration, establish connections
pub async fn bloodsniffer_initialize(config: Config) -> Result<AppState> {
    // Load configuration
    let state = AppState::new(config).await?;

    Ok(state)
}

/// Create daemon context (dictionary: bloodsniffer_create_daemon_context)
/// Pseudocode: Create context for background daemon operations
#[cfg(unix)]
pub fn bloodsniffer_create_daemon_context() -> tokio::task::JoinHandle<()> {
    tokio::spawn(async {
        // Handle daemon operations
        let mut sigterm = signal::unix::signal(signal::unix::SignalKind::terminate())
            .expect("Failed to install SIGTERM handler");

        sigterm.recv().await;
    })
}

#[cfg(not(unix))]
pub fn bloodsniffer_create_daemon_context() -> tokio::task::JoinHandle<()> {
    tokio::spawn(async {
        // Windows daemon context
        signal::ctrl_c()
            .await
            .expect("Failed to install Ctrl+C handler");
    })
}

/// Migrate database (dictionary: bloodsniffer_migrate_db)
/// Pseudocode: Run database migrations to update schema
pub async fn bloodsniffer_migrate_db(state: &AppState) -> Result<()> {
    // Open database connection
    let db = RedbDatabase::open(&state.config.database.path).context("Failed to open database")?;

    // Run migrations
    db.migrate().context("Failed to run migrations")?;

    // Check if installation exists
    let has_installation = db
        .has_installation()
        .context("Failed to check installation")?;

    if has_installation {
        return Ok(());
    }

    // Create default admin if no installation exists
    bloodsniffer_create_default_admin_internal(&db, &state.config).await?;

    Ok(())
}

/// Create default admin (dictionary: bloodsniffer_create_default_admin)
/// Pseudocode: Create default administrator user if none exists
pub async fn bloodsniffer_create_default_admin(state: &AppState) -> Result<()> {
    let db = RedbDatabase::open(&state.config.database.path).context("Failed to open database")?;

    bloodsniffer_create_default_admin_internal(&db, &state.config).await
}

/// Internal function to create default admin
async fn bloodsniffer_create_default_admin_internal(
    db: &RedbDatabase,
    config: &Config,
) -> Result<()> {
    // Get all roles
    let roles = db.get_all_roles().context("Failed to get roles")?;

    // Find administrator role
    let admin_role = roles
        .iter()
        .find(|r| r.name == Role::ADMINISTRATOR)
        .ok_or_else(|| anyhow::anyhow!("Administrator role not found"))?;

    // Check if user already exists
    if let Some(existing_user) = db.lookup_user(&config.default_admin.principal_name)? {
        // Delete existing user
        db.delete_user(&existing_user)
            .context("Failed to delete existing user")?;
    }

    // Create password digest using Argon2
    let hasher = PasswordHasher::new();
    let password_digest = hasher
        .hash_password(&config.default_admin.password)
        .context("Failed to hash password")?;

    // Create auth secret
    let auth_secret = AuthSecret {
        digest: password_digest,
        digest_method: "argon2".to_string(),
        expires_at: if config.default_admin.expire_now {
            None
        } else {
            Some(Utc::now() + chrono::Duration::days(90))
        },
    };

    // Create admin user with auth secret
    let admin_user = User {
        id: uuid::Uuid::new_v4(),
        principal_name: config.default_admin.principal_name.clone(),
        email_address: Some(config.default_admin.email_address.clone()),
        first_name: Some(config.default_admin.first_name.clone()),
        last_name: Some(config.default_admin.last_name.clone()),
        all_environments: true,
        roles: vec![admin_role.clone()],
        auth_secret: Some(auth_secret.clone()),
    };

    // Initialize secret auth
    db.initialize_secret_auth(&admin_user, &auth_secret)
        .context("Failed to initialize secret auth")?;

    db.create_installation()
        .context("Failed to record installation")?;

    // Print password message
    let password_msg = format!(
        "# Initial Password Set To:    {}    #",
        config.default_admin.password
    );
    let padding = " ".repeat(password_msg.len() - 2);
    let border = "#".repeat(password_msg.len());

    println!("{}", border);
    println!("#{}#", padding);
    println!("{}", password_msg);
    println!("#{}#", padding);
    println!("{}", border);

    Ok(())
}

/// Ensure server directories (dictionary: bloodsniffer_ensure_directories)
/// Pseudocode: Create required directories for server operation
pub fn bloodsniffer_ensure_directories(config: &Config) -> Result<()> {
    // Create data directory
    if let Some(parent) = config.database.path.parent() {
        std::fs::create_dir_all(parent)?;
    }

    // Create cryptex directory
    std::fs::create_dir_all("./cryptex")?;

    // Create pipeline work directory
    std::fs::create_dir_all(&config.pipeline.work_dir)?;

    Ok(())
}

/// Default config file path (dictionary: bloodsniffer_default_config_path)
/// Pseudocode: Get default path for configuration file
pub fn bloodsniffer_default_config_path() -> String {
    "bloodsniffer.toml".to_string()
}

/// Connect to graph database (dictionary: bloodsniffer_connect_graph)
/// Pseudocode: Establish connection to graph database (Neo4j/PostgreSQL)
pub async fn bloodsniffer_connect_graph(_config: &Config) -> Result<()> {
    // TODO: Implement graph database connection
    // Based on Go: ConnectGraph function
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[tokio::test]
    async fn test_bloodsniffer_initialize() {
        let config = Config::default();
        let result = bloodsniffer_initialize(config).await;
        assert!(result.is_ok());
    }

    #[test]
    fn test_bloodsniffer_ensure_directories() {
        let config = Config::default();
        let result = bloodsniffer_ensure_directories(&config);
        assert!(result.is_ok());
    }
}

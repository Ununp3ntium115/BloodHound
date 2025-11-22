// ReDB database implementation

use anyhow::{Context, Result};
use redb::{Database, ReadableTable, TableDefinition};
use std::path::Path;
use std::sync::Arc;

use super::models::{AuthSecret, Installation, Role, User, UserSession};
use super::Database as DatabaseTrait;

const USERS_TABLE: TableDefinition<&str, &[u8]> = TableDefinition::new("users");
const ROLES_TABLE: TableDefinition<&str, &[u8]> = TableDefinition::new("roles");
const INSTALLATION_TABLE: TableDefinition<&str, &[u8]> = TableDefinition::new("installation");
const SESSIONS_TABLE: TableDefinition<&str, &[u8]> = TableDefinition::new("sessions");

/// ReDB database implementation
pub struct RedbDatabase {
    db: Arc<Database>,
}

impl RedbDatabase {
    /// Open or create database
    pub fn open<P: AsRef<Path>>(path: P) -> Result<Self> {
        let db = Database::create(path).context("Failed to create database")?;

        // Initialize tables
        let write_txn = db
            .begin_write()
            .context("Failed to begin write transaction")?;
        {
            write_txn
                .open_table(USERS_TABLE)
                .context("Failed to open users table")?;
            write_txn
                .open_table(ROLES_TABLE)
                .context("Failed to open roles table")?;
            write_txn
                .open_table(INSTALLATION_TABLE)
                .context("Failed to open installation table")?;
            write_txn
                .open_table(SESSIONS_TABLE)
                .context("Failed to open sessions table")?;
        }
        write_txn.commit().context("Failed to commit transaction")?;

        Ok(Self { db: Arc::new(db) })
    }
}

impl DatabaseTrait for RedbDatabase {
    fn migrate(&self) -> Result<()> {
        // Ensure tables exist
        let write_txn = self
            .db
            .begin_write()
            .context("Failed to begin write transaction")?;
        {
            write_txn.open_table(USERS_TABLE)?;
            write_txn.open_table(ROLES_TABLE)?;
            write_txn.open_table(INSTALLATION_TABLE)?;
            write_txn.open_table(SESSIONS_TABLE)?;
        }
        write_txn.commit()?;
        Ok(())
    }

    fn has_installation(&self) -> Result<bool> {
        let read_txn = self
            .db
            .begin_read()
            .context("Failed to begin read transaction")?;
        let table = read_txn
            .open_table(INSTALLATION_TABLE)
            .context("Failed to open table")?;

        let has_install = table
            .get("installation")
            .context("Failed to get installation")?
            .is_some();
        Ok(has_install)
    }

    fn create_installation(&self) -> Result<Installation> {
        let installation = Installation {
            id: uuid::Uuid::new_v4(),
            created_at: chrono::Utc::now(),
        };

        let data = serde_json::to_vec(&installation)?;

        let write_txn = self
            .db
            .begin_write()
            .context("Failed to begin write transaction")?;
        {
            let mut table = write_txn
                .open_table(INSTALLATION_TABLE)
                .context("Failed to open table")?;
            table.insert("installation", data.as_slice())?;
        }
        write_txn.commit()?;

        Ok(installation)
    }

    fn get_all_roles(&self) -> Result<Vec<Role>> {
        let read_txn = self
            .db
            .begin_read()
            .context("Failed to begin read transaction")?;
        let table = read_txn
            .open_table(ROLES_TABLE)
            .context("Failed to open table")?;

        let mut roles = Vec::new();
        let iter = table.iter().context("Failed to create iterator")?;

        for item in iter {
            let (_, value) = item.context("Failed to read item")?;
            let role: Role = serde_json::from_slice(value.value())?;
            roles.push(role);
        }

        // If no roles exist, create default roles
        if roles.is_empty() {
            roles.push(Role {
                id: uuid::Uuid::new_v4(),
                name: Role::ADMINISTRATOR.to_string(),
                description: Some("Administrator role".to_string()),
            });
        }

        Ok(roles)
    }

    fn lookup_user(&self, principal_name: &str) -> Result<Option<User>> {
        let read_txn = self
            .db
            .begin_read()
            .context("Failed to begin read transaction")?;
        let table = read_txn
            .open_table(USERS_TABLE)
            .context("Failed to open table")?;

        if let Some(data) = table.get(principal_name).context("Failed to get user")? {
            let user: User = serde_json::from_slice(data.value())?;
            Ok(Some(user))
        } else {
            Ok(None)
        }
    }

    fn delete_user(&self, user: &User) -> Result<()> {
        let write_txn = self
            .db
            .begin_write()
            .context("Failed to begin write transaction")?;
        {
            let mut table = write_txn
                .open_table(USERS_TABLE)
                .context("Failed to open table")?;
            table.remove(user.principal_name.as_str())?;
        }
        write_txn.commit()?;
        Ok(())
    }

    fn initialize_secret_auth(&self, user: &User, _secret: &AuthSecret) -> Result<User> {
        let data = serde_json::to_vec(user)?;

        let write_txn = self
            .db
            .begin_write()
            .context("Failed to begin write transaction")?;
        {
            let mut table = write_txn
                .open_table(USERS_TABLE)
                .context("Failed to open table")?;
            table.insert(user.principal_name.as_str(), data.as_slice())?;
        }
        write_txn.commit()?;

        Ok(user.clone())
    }

    fn create_session(&self, session: &UserSession) -> Result<()> {
        let data = serde_json::to_vec(session)?;

        let write_txn = self
            .db
            .begin_write()
            .context("Failed to begin write transaction")?;
        {
            let mut table = write_txn
                .open_table(SESSIONS_TABLE)
                .context("Failed to open table")?;
            table.insert(session.token.as_str(), data.as_slice())?;
        }
        write_txn.commit()?;
        Ok(())
    }

    fn get_session(&self, token: &str) -> Result<Option<UserSession>> {
        let read_txn = self
            .db
            .begin_read()
            .context("Failed to begin read transaction")?;
        let table = read_txn
            .open_table(SESSIONS_TABLE)
            .context("Failed to open table")?;

        if let Some(data) = table.get(token).context("Failed to get session")? {
            let session: UserSession = serde_json::from_slice(data.value())?;
            Ok(Some(session))
        } else {
            Ok(None)
        }
    }

    fn get_user_session(&self, session_id: &uuid::Uuid) -> Result<Option<UserSession>> {
        // Find session by ID (simplified - in production, maintain an index)
        let read_txn = self
            .db
            .begin_read()
            .context("Failed to begin read transaction")?;
        let table = read_txn
            .open_table(SESSIONS_TABLE)
            .context("Failed to open table")?;

        let iter = table.iter().context("Failed to create iterator")?;

        for item in iter {
            let (_token, value) = item.context("Failed to read item")?;
            if let Ok(session) = serde_json::from_slice::<UserSession>(value.value()) {
                if session.id == *session_id {
                    return Ok(Some(session));
                }
            }
        }

        Ok(None)
    }

    fn end_user_session(&self, session_id: &uuid::Uuid) -> Result<()> {
        self.delete_session(session_id)
    }

    fn delete_session(&self, session_id: &uuid::Uuid) -> Result<()> {
        // Find session by ID (simplified - in production, maintain an index)
        let read_txn = self
            .db
            .begin_read()
            .context("Failed to begin read transaction")?;
        let table = read_txn
            .open_table(SESSIONS_TABLE)
            .context("Failed to open table")?;

        let iter = table.iter().context("Failed to create iterator")?;
        let mut token_to_delete = None;

        for item in iter {
            let (token, value) = item.context("Failed to read item")?;
            if let Ok(session) = serde_json::from_slice::<UserSession>(value.value()) {
                if session.id == *session_id {
                    token_to_delete = Some(token.value().to_string());
                    break;
                }
            }
        }

        if let Some(token) = token_to_delete {
            let write_txn = self
                .db
                .begin_write()
                .context("Failed to begin write transaction")?;
            {
                let mut table = write_txn
                    .open_table(SESSIONS_TABLE)
                    .context("Failed to open table")?;
                table.remove(token.as_str())?;
            }
            write_txn.commit()?;
        }

        Ok(())
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::database::models::{AuthSecret, Role, User};
    use std::fs;
    use tempfile::TempDir;

    fn create_test_db() -> (RedbDatabase, TempDir) {
        let temp_dir = TempDir::new().unwrap();
        let db_path = temp_dir.path().join("test.db");
        let db = RedbDatabase::open(&db_path).unwrap();
        (db, temp_dir)
    }

    #[test]
    fn test_migrate() {
        let (db, _temp) = create_test_db();
        assert!(db.migrate().is_ok());
    }

    #[test]
    fn test_installation() {
        let (db, _temp) = create_test_db();

        // Initially no installation
        assert!(!db.has_installation().unwrap());

        // Create installation
        let installation = db.create_installation().unwrap();
        assert!(!installation.id.is_nil());

        // Now has installation
        assert!(db.has_installation().unwrap());
    }

    #[test]
    fn test_roles() {
        let (db, _temp) = create_test_db();

        // Get roles (should create default admin role)
        let roles = db.get_all_roles().unwrap();
        assert!(!roles.is_empty());
        assert!(roles.iter().any(|r| r.name == Role::ADMINISTRATOR));
    }

    #[test]
    fn test_user_crud() {
        let (db, _temp) = create_test_db();

        // Create user
        let user = User {
            id: uuid::Uuid::new_v4(),
            principal_name: "test_user".to_string(),
            email_address: Some("test@example.com".to_string()),
            first_name: Some("Test".to_string()),
            last_name: Some("User".to_string()),
            all_environments: true,
            roles: vec![],
            auth_secret: None,
        };

        let secret = AuthSecret {
            digest: "test_hash".to_string(),
            digest_method: "argon2".to_string(),
            expires_at: None,
        };

        // Initialize auth
        let saved_user = db.initialize_secret_auth(&user, &secret).unwrap();
        assert_eq!(saved_user.principal_name, "test_user");

        // Lookup user
        let found_user = db.lookup_user("test_user").unwrap();
        assert!(found_user.is_some());
        assert_eq!(found_user.unwrap().principal_name, "test_user");

        // Delete user
        db.delete_user(&saved_user).unwrap();

        // User should be gone
        let found_user = db.lookup_user("test_user").unwrap();
        assert!(found_user.is_none());
    }

    #[test]
    fn test_session_crud() {
        let (db, _temp) = create_test_db();

        let session = UserSession {
            id: uuid::Uuid::new_v4(),
            user_id: uuid::Uuid::new_v4(),
            token: "test_token_123".to_string(),
            created_at: chrono::Utc::now(),
            expires_at: chrono::Utc::now() + chrono::Duration::hours(24),
        };

        // Create session
        db.create_session(&session).unwrap();

        // Get session
        let found_session = db.get_session("test_token_123").unwrap();
        assert!(found_session.is_some());
        assert_eq!(found_session.unwrap().token, "test_token_123");

        // Delete session
        db.delete_session(&session.id).unwrap();

        // Session should be gone
        let found_session = db.get_session("test_token_123").unwrap();
        assert!(found_session.is_none());
    }
}

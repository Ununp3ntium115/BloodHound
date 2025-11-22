// Cryptographic functions for authentication
// Password hashing using Argon2

use anyhow::Result;
use argon2::{
    password_hash::{PasswordHasher as Argon2PasswordHasher, PasswordVerifier, SaltString},
    Argon2,
};
use rand::rngs::OsRng;

/// Password hasher using Argon2
pub struct PasswordHasher {
    argon2: Argon2<'static>,
}

impl PasswordHasher {
    /// Create new password hasher
    pub fn new() -> Self {
        Self {
            argon2: Argon2::default(),
        }
    }

    /// Hash a password
    pub fn hash_password(&self, password: &str) -> Result<String> {
        let salt = SaltString::generate(&mut OsRng);
        let password_hash = <Argon2 as Argon2PasswordHasher>::hash_password(
            &self.argon2,
            password.as_bytes(),
            &salt,
        )
        .map_err(|e| anyhow::anyhow!("Failed to hash password: {}", e))?;

        Ok(password_hash.to_string())
    }

    /// Verify a password against a hash
    pub fn verify_password(&self, password: &str, hash: &str) -> Result<bool> {
        let parsed_hash = argon2::password_hash::PasswordHash::new(hash)
            .map_err(|e| anyhow::anyhow!("Failed to parse hash: {}", e))?;

        match <Argon2 as PasswordVerifier>::verify_password(
            &self.argon2,
            password.as_bytes(),
            &parsed_hash,
        ) {
            Ok(()) => Ok(true),
            Err(argon2::password_hash::Error::Password) => Ok(false),
            Err(e) => Err(anyhow::anyhow!("Verification error: {}", e)),
        }
    }
}

impl Default for PasswordHasher {
    fn default() -> Self {
        Self::new()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_password_hashing() {
        let hasher = PasswordHasher::new();
        let password = "test_password_123";

        let hash = hasher.hash_password(password).unwrap();
        assert!(!hash.is_empty());

        let verified = hasher.verify_password(password, &hash).unwrap();
        assert!(verified);

        let wrong = hasher.verify_password("wrong_password", &hash).unwrap();
        assert!(!wrong);
    }

    #[test]
    fn test_different_passwords_produce_different_hashes() {
        let hasher = PasswordHasher::new();
        let password = "same_password";

        let hash1 = hasher.hash_password(password).unwrap();
        let hash2 = hasher.hash_password(password).unwrap();

        // Hashes should be different due to salt
        assert_ne!(hash1, hash2);

        // But both should verify correctly
        assert!(hasher.verify_password(password, &hash1).unwrap());
        assert!(hasher.verify_password(password, &hash2).unwrap());
    }

    #[test]
    fn test_empty_password() {
        let hasher = PasswordHasher::new();
        let hash = hasher.hash_password("").unwrap();
        assert!(hasher.verify_password("", &hash).unwrap());
        assert!(!hasher.verify_password("not_empty", &hash).unwrap());
    }
}

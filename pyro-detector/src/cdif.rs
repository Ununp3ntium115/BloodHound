/// CDIF (Critical Digital Investigation Fire Marshal) Compliance
/// 
/// This module ensures all terminology and operations comply with
/// Fire Marshal Cryptex v2.0 standards.

/// Validate Fire Marshal terminology
pub fn validate_terminology(term: &str) -> Result<(), String> {
    let invalid_terms = vec![
        ("hunt", "investigation"),
        ("artifact", "detonator"),
        ("client", "agent"),
        ("execution", "collection"),
        ("session", "case"),
    ];

    for (invalid, correct) in invalid_terms {
        if term.to_lowercase().contains(invalid) {
            return Err(format!(
                "Invalid terminology: '{}'. Use '{}' instead (CDIF compliance)",
                invalid, correct
            ));
        }
    }

    Ok(())
}

/// Convert terminology to Fire Marshal standard
pub fn convert_to_fire_marshal(term: &str) -> String {
    let conversions = vec![
        ("hunt", "investigation"),
        ("artifact", "detonator"),
        ("client", "agent"),
        ("execution", "collection"),
        ("session", "case"),
    ];

    let mut result = term.to_string();
    for (invalid, correct) in conversions {
        result = result.replace(invalid, correct);
        result = result.replace(&invalid.to_uppercase(), &correct.to_uppercase());
    }

    result
}

/// CDIF compliance check
pub struct CdifCompliance {
    pub fire_marshal_terminology: bool,
    pub quantum_verification: bool,
    pub evidence_chain: bool,
}

impl CdifCompliance {
    pub fn new() -> Self {
        Self {
            fire_marshal_terminology: true,
            quantum_verification: true,
            evidence_chain: true,
        }
    }

    pub fn validate(&self, data: &serde_json::Value) -> Result<(), Vec<String>> {
        let mut errors = Vec::new();

        // Check terminology
        if self.fire_marshal_terminology {
            if let Some(text) = data.as_str() {
                if let Err(e) = validate_terminology(text) {
                    errors.push(e);
                }
            }
        }

        // Check for required CDIF fields
        if self.evidence_chain {
            if !data.as_object()
                .and_then(|o| o.get("evidence_chain"))
                .is_some() {
                errors.push("Missing evidence_chain (CDIF requirement)".to_string());
            }
        }

        if errors.is_empty() {
            Ok(())
        } else {
            Err(errors)
        }
    }
}

impl Default for CdifCompliance {
    fn default() -> Self {
        Self::new()
    }
}


/// BloodSniffer - Anarchist Branding Module
/// "From the ashes of the old, we build the new"

pub fn print_banner() {
    let banner = r#"
    ╔═══════════════════════════════════════════════════════════╗
    ║                                                           ║
    ║   ██████╗ ██╗      ██████╗  ██████╗ ██████╗ ███████╗      ║
    ║   ██╔══██╗██║     ██╔═══██╗██╔══██╗██╔══██╗██╔════╝      ║
    ║   ██████╔╝██║     ██║   ██║██║  ██║██║  ██║███████╗      ║
    ║   ██╔══██╗██║     ██║   ██║██║  ██║██║  ██║╚════██║      ║
    ║   ██████╔╝███████╗╚██████╔╝██████╔╝██████╔╝███████║      ║
    ║   ╚═════╝ ╚══════╝ ╚═════╝ ╚═════╝ ╚═════╝ ╚══════╝      ║
    ║                                                           ║
    ║        🩸 AUTONOMOUS DATA LIBERATION SYSTEM 🩸           ║
    ║                                                           ║
    ║   "No gods, no masters, only autonomous systems"         ║
    ║                                                           ║
    ║   Components:                                            ║
    ║   • Cryptex - Secure Data Compartmentalization           ║
    ║   • Fire Marshal - Data Flow Orchestration              ║
    ║   • Node-RED Bridge - Autonomous Data Pipelines         ║
    ║                                                           ║
    ╚═══════════════════════════════════════════════════════════╝
    "#;

    println!("{}", banner);
}

pub struct PyroTheme {
    pub primary_color: String,
    pub secondary_color: String,
    pub accent_color: String,
    pub name: String,
}

impl PyroTheme {
    pub fn anarchist() -> Self {
        Self {
            primary_color: "#FF0000".to_string(),   // Red
            secondary_color: "#000000".to_string(), // Black
            accent_color: "#FF6600".to_string(),    // Orange/Fire
            name: "Anarchist Flame".to_string(),
        }
    }

    pub fn fire_marshal() -> Self {
        Self {
            primary_color: "#FF4500".to_string(),   // Orange Red
            secondary_color: "#8B0000".to_string(), // Dark Red
            accent_color: "#FFD700".to_string(),    // Gold
            name: "Fire Marshal".to_string(),
        }
    }
}

pub struct Manifesto;

impl Manifesto {
    pub fn principles() -> Vec<&'static str> {
        vec![
            "Autonomous operation - no central control",
            "Data sovereignty - encrypt and compartmentalize",
            "Horizontal organization - peer-to-peer architecture",
            "Mutual aid - share resources without hierarchy",
            "Direct action - execute without permission",
            "Decentralization - distribute power and data",
        ]
    }

    pub fn print_principles() {
        println!("\n🔥 PYRO PRINCIPLES 🔥\n");
        for (i, principle) in Self::principles().iter().enumerate() {
            println!("  {}. {}", i + 1, principle);
        }
        println!();
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_themes() {
        let anarchist = PyroTheme::anarchist();
        assert_eq!(anarchist.name, "Anarchist Flame");

        let fire_marshal = PyroTheme::fire_marshal();
        assert_eq!(fire_marshal.name, "Fire Marshal");
    }

    #[test]
    fn test_principles() {
        let principles = Manifesto::principles();
        assert!(!principles.is_empty());
        assert!(principles[0].contains("Autonomous"));
    }
}

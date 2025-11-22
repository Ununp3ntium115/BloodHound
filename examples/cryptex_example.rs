// Example: Using Cryptex to organize functions with anarchist naming

use cryptex::Cryptex;
use std::path::PathBuf;

fn main() -> anyhow::Result<()> {
    // Create a new Cryptex structure
    let cryptex_path = PathBuf::from("./example_cryptex");
    let mut cryptex = Cryptex::new(&cryptex_path)?;

    // Add root function: extract_data
    let extract_node = cryptex.add_function(
        None,
        "extract_data".to_string(),
        r#"fn extract_data(source: &str) -> Result<Data> {
    // Extract data from source
    // This is the root function
    todo!()
}"#
        .to_string(),
        "Extract data from the source system. This is the entry point.".to_string(),
    )?;

    println!("Created function: {}", extract_node.path_name);

    // Add child function: parse_nodes (parent is extract_data)
    let parse_nodes = cryptex.add_function(
        Some(extract_node.path_name.clone()),
        "parse_nodes".to_string(),
        r#"fn parse_nodes(data: &Value) -> Result<Vec<Node>> {
    // Parse nodes from extracted data
    // Called by extract_data
    todo!()
}"#
        .to_string(),
        "Parse nodes from the extracted data structure. Processes user, computer, and group objects.".to_string(),
    )?;

    println!("Created function: {}", parse_nodes.path_name);

    // Add another child: parse_edges
    let parse_edges = cryptex.add_function(
        Some(extract_node.path_name.clone()),
        "parse_edges".to_string(),
        r#"fn parse_edges(data: &Value) -> Result<Vec<Edge>> {
    // Parse edges/relationships from extracted data
    // Called by extract_data
    todo!()
}"#
        .to_string(),
        "Parse edges and relationships from the extracted data. Maps connections between nodes.".to_string(),
    )?;

    println!("Created function: {}", parse_edges.path_name);

    // Add grandchild: process_nodes (parent is parse_nodes)
    let process_nodes = cryptex.add_function(
        Some(parse_nodes.path_name.clone()),
        "process_nodes".to_string(),
        r#"fn process_nodes(nodes: Vec<Node>) -> Result<ProcessedNodes> {
    // Process and validate parsed nodes
    // Called by parse_nodes
    todo!()
}"#
        .to_string(),
        "Process and validate the parsed nodes. Applies business logic and validation rules.".to_string(),
    )?;

    println!("Created function: {}", process_nodes.path_name);

    // List all functions
    println!("\nAll functions in cryptex:");
    for func in cryptex.list_functions() {
        println!("  - {} (parent: {:?})", func.name, func.parent);
    }

    // Export structure
    let structure = cryptex.export_structure()?;
    println!("\nCryptex structure (JSON):");
    println!("{}", structure);

    Ok(())
}


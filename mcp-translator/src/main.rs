use anyhow::Result;
use mcp_translator::server::McpTranslatorServer;

#[tokio::main]
async fn main() -> Result<()> {
    println!("🔧 MCP Translator Server - Converting source code to Cryptex");
    println!("   Autonomous code organization with anarchist naming\n");

    let mut server = McpTranslatorServer::new()?;
    server.run().await?;

    Ok(())
}

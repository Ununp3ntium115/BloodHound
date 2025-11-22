#!/bin/bash
# Setup script for PYRO Detector MCP Server

set -e

echo "🔥 PYRO Detector Setup"
echo "======================"
echo ""

# Check if Rust is installed
if ! command -v cargo &> /dev/null; then
    echo "❌ Rust/Cargo not found. Please install Rust first:"
    echo "   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
    exit 1
fi

echo "✅ Rust/Cargo found"
echo ""

# Build the project
echo "📦 Building PYRO Detector..."
cargo build --release

if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
else
    echo "❌ Build failed"
    exit 1
fi

echo ""

# Create config file if it doesn't exist
if [ ! -f "pyro-detector-config.json" ]; then
    echo "📝 Creating configuration file..."
    cp pyro-detector-config.json.example pyro-detector-config.json
    echo "✅ Configuration file created: pyro-detector-config.json"
    echo "   Please edit it with your PYRO Platform Ignition settings"
else
    echo "✅ Configuration file already exists"
fi

echo ""
echo "🎉 Setup complete!"
echo ""
echo "Next steps:"
echo "1. Edit pyro-detector-config.json with your API settings"
echo "2. Add to Cursor MCP configuration (see mcp-config.json)"
echo "3. Test: ./target/release/pyro-detector"
echo ""

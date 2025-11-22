#!/bin/bash
# Build script for Pyro (Linux/macOS)

set -e

BUILD_TYPE="${1:-release}"
echo "🩸 Building BloodSniffer - Autonomous Data Liberation System"

# Build Rust project
echo ""
echo "Building Rust project..."
cargo build --$BUILD_TYPE

if [ $? -ne 0 ]; then
    echo "Build failed!"
    exit 1
fi

echo "Build successful!"

# Create output directory
OUTPUT_DIR="dist"
mkdir -p $OUTPUT_DIR

# Copy binaries
echo ""
echo "Copying binaries..."
BIN_DIR="target/$BUILD_TYPE"

if [ -f "$BIN_DIR/bloodsniffer" ]; then
    cp "$BIN_DIR/bloodsniffer" "$OUTPUT_DIR/"
    echo "  ✓ bloodsniffer"
fi

if [ -f "$BIN_DIR/fire-marshal" ]; then
    cp "$BIN_DIR/fire-marshal" "$OUTPUT_DIR/"
    echo "  ✓ fire-marshal"
fi

# Copy documentation
cp README.md "$OUTPUT_DIR/" 2>/dev/null || true
cp LICENSE "$OUTPUT_DIR/" 2>/dev/null || true

echo ""
echo "🩸 Build complete! Output in: $OUTPUT_DIR"


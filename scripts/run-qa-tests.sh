#!/bin/bash
# Run QA and UA tests

echo "🩸 Running QA Tests..."
echo ""

# Run unit tests
echo "📦 Running unit tests..."
cargo test --lib -- --nocapture

# Run integration tests
echo ""
echo "🔗 Running integration tests..."
cargo test --test '*' -- --nocapture

# Run with coverage
echo ""
echo "📊 Generating coverage report..."
cargo test --coverage

echo ""
echo "✅ QA tests complete!"


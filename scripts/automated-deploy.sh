#!/bin/bash
# Automated deployment script

set -e

echo "🩸 Starting automated deployment..."
echo ""

# Run tests first
echo "1. Running tests..."
cargo test

# Run gap analysis
echo ""
echo "2. Running gap analysis..."
./scripts/run-gap-analysis.sh > gap-analysis-report.json

# Check coverage
COVERAGE=$(jq -r '.coverage_percent' gap-analysis-report.json)
echo ""
echo "3. Coverage: ${COVERAGE}%"

if (( $(echo "$COVERAGE < 80" | bc -l) )); then
    echo "⚠️  Coverage below 80%, deployment blocked"
    exit 1
fi

# Build release
echo ""
echo "4. Building release..."
cargo build --release

# Run QA tests
echo ""
echo "5. Running QA tests..."
./scripts/run-qa-tests.sh

# Create release package
echo ""
echo "6. Creating release package..."
mkdir -p dist
cp target/release/bloodsniffer dist/
cp target/release/fire-marshal dist/
cp README_BLOODSNIFFER.md dist/

# Tag and push (if on main branch)
if [ "$(git branch --show-current)" = "main" ]; then
    echo ""
    echo "7. Tagging release..."
    VERSION=$(cargo metadata --format-version 1 | jq -r '.packages[0].version')
    git tag -a "v${VERSION}" -m "Release v${VERSION}"
    git push origin "v${VERSION}"
fi

echo ""
echo "✅ Deployment complete!"


# Quality Assurance & User Acceptance Testing

## Overview

Quality Assurance (QA) and User Acceptance (UA) testing framework for BloodSniffer.

## Test Structure

```
qa/
  unit/          - Unit tests
  integration/   - Integration tests
  ua/            - User acceptance tests
  e2e/           - End-to-end tests
  performance/   - Performance tests
```

## Running Tests

```bash
# Run all tests
cargo test

# Run unit tests only
cargo test --lib

# Run integration tests
cargo test --test '*'

# Run with coverage
cargo test --coverage
```

## QA Checklist

- [ ] All functions implemented
- [ ] Unit tests passing
- [ ] Integration tests passing
- [ ] Performance benchmarks met
- [ ] Security audit passed
- [ ] Documentation complete
- [ ] Code coverage > 80%

## UA Checklist

- [ ] User workflows tested
- [ ] API endpoints functional
- [ ] Data extraction working
- [ ] Cryptex structure correct
- [ ] Node-RED integration working
- [ ] Installation successful
- [ ] Configuration working


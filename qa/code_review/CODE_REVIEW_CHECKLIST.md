# PYRO Detector - Code Review Checklist

## Pre-Review Checklist

### Code Quality
- [ ] Code follows project style guide
- [ ] No hardcoded values (use configuration)
- [ ] Error handling is comprehensive
- [ ] No TODO/FIXME comments in production code
- [ ] Code is well-commented
- [ ] Functions are appropriately sized (< 100 lines)

### Security
- [ ] No sensitive data in code
- [ ] Input validation implemented
- [ ] Output sanitization implemented
- [ ] Authentication/authorization checked
- [ ] No SQL injection vulnerabilities
- [ ] No XSS vulnerabilities
- [ ] Dependencies are up to date

### Performance
- [ ] No obvious performance bottlenecks
- [ ] Efficient algorithms used
- [ ] Resource cleanup (memory, files, connections)
- [ ] No unnecessary database queries
- [ ] Caching used where appropriate

### Testing
- [ ] Unit tests added/updated
- [ ] Integration tests added/updated
- [ ] Tests pass locally
- [ ] Edge cases covered
- [ ] Error cases tested

### Documentation
- [ ] Code is self-documenting
- [ ] Complex logic has comments
- [ ] API changes documented
- [ ] README updated if needed
- [ ] Changelog updated

### Rust-Specific
- [ ] No unsafe code (or properly justified)
- [ ] Proper error types used
- [ ] Ownership and borrowing correct
- [ ] No unwrap() in production code
- [ ] Proper use of Result/Option
- [ ] Clippy warnings addressed

### Go-Specific
- [ ] Proper error handling
- [ ] Context used for cancellation
- [ ] No goroutine leaks
- [ ] Proper resource cleanup
- [ ] No race conditions
- [ ] go vet passes
- [ ] golangci-lint passes

### TypeScript/React-Specific
- [ ] TypeScript types are strict
- [ ] No any types (or properly justified)
- [ ] React hooks used correctly
- [ ] No memory leaks
- [ ] Proper error boundaries
- [ ] Accessibility considered
- [ ] ESLint passes

## Review Focus Areas

### PYRO Detector Specific
- [ ] CDIF compliance maintained
- [ ] Fire Marshal terminology used
- [ ] Evidence chain preserved
- [ ] Logging implemented
- [ ] Performance metrics tracked

### Integration Points
- [ ] MCP protocol compliance
- [ ] API contract maintained
- [ ] Backward compatibility
- [ ] Data format consistency

## Review Process

1. **Initial Review**
   - Check checklist items
   - Run automated tools (linters, formatters)
   - Review code structure

2. **Detailed Review**
   - Review logic and algorithms
   - Check error handling
   - Verify security

3. **Testing Review**
   - Verify tests are adequate
   - Check test coverage
   - Review test quality

4. **Documentation Review**
   - Verify documentation is updated
   - Check code comments
   - Review API documentation

5. **Final Approval**
   - All checklist items pass
   - All tests pass
   - Documentation complete
   - Ready to merge

## Automated Checks

### Rust
```bash
cargo clippy --all-targets -- -D warnings
cargo fmt --check
cargo test
```

### Go
```bash
go vet ./...
golangci-lint run
go test ./...
```

### TypeScript
```bash
npm run lint
npm run type-check
npm test
```

## Review Criteria

### Must Fix (Blocking)
- Security vulnerabilities
- Data loss risks
- Breaking changes without migration
- Performance regressions
- Test failures

### Should Fix (Non-blocking)
- Code style issues
- Documentation gaps
- Test coverage gaps
- Minor performance issues
- Code complexity

### Nice to Have
- Code optimizations
- Additional tests
- Documentation improvements
- Refactoring opportunities

---

**Use this checklist for all code reviews to ensure quality and consistency.**


#!/usr/bin/env python3
"""
Generate comprehensive TODO list from gap analysis and code review
"""

import json
import os
import subprocess
from pathlib import Path

def run_gap_analysis():
    """Run gap analysis via MCP server"""
    print("Running gap analysis...")
    try:
        result = subprocess.run(
            ["cargo", "run", "--bin", "mcp-translator"],
            input=json.dumps({
                "jsonrpc": "2.0",
                "id": 1,
                "method": "gap_analysis",
                "params": {
                    "go_source_path": "./cmd/api/src",
                    "rust_source_path": "./bloodsniffer-core/src"
                }
            }),
            text=True,
            capture_output=True,
            timeout=60
        )
        if result.returncode == 0:
            return json.loads(result.stdout)
    except Exception as e:
        print(f"Error running gap analysis: {e}")
    return None

def analyze_go_modules():
    """Analyze Go modules to understand structure"""
    modules = {}
    go_src = Path("cmd/api/src")
    
    if not go_src.exists():
        return modules
    
    for module_dir in go_src.iterdir():
        if module_dir.is_dir():
            go_files = list(module_dir.rglob("*.go"))
            if go_files:
                modules[module_dir.name] = len(go_files)
    
    return modules

def generate_todos():
    """Generate comprehensive TODO list"""
    todos = []
    todo_num = 1
    
    # Get gap analysis
    gap_data = run_gap_analysis()
    
    # Analyze modules
    go_modules = analyze_go_modules()
    
    print("\n🩸 Generating Comprehensive TODO List\n")
    print("=" * 60)
    
    # Phase 1: Core Implementation
    print("\n## Phase 1: Core Implementation (1-30%)")
    print("-" * 60)
    
    if gap_data and "result" in gap_data:
        result = gap_data["result"]
        missing = result.get("missing", [])
        
        # Group by module
        by_module = {}
        for func in missing:
            module = func.get("module", "unknown")
            if module not in by_module:
                by_module[module] = []
            by_module[module].append(func)
        
        for module_name, funcs in sorted(by_module.items()):
            print(f"\n### {module_name.upper()} Module ({len(funcs)} functions)")
            for func in funcs[:10]:  # Limit to first 10 per module
                print(f"{todo_num}. [ ] Implement `{func['name']}`")
                print(f"   - Module: {module_name}")
                print(f"   - File: {func['file']}")
                print(f"   - Signature: {func['signature'][:80]}...")
                todos.append({
                    "id": todo_num,
                    "module": module_name,
                    "function": func['name'],
                    "file": func['file'],
                    "priority": "high"
                })
                todo_num += 1
            if len(funcs) > 10:
                print(f"   ... and {len(funcs) - 10} more functions")
    
    # Phase 2: Testing
    print("\n## Phase 2: Testing & QA (30-60%)")
    print("-" * 60)
    
    for module in go_modules.keys():
        print(f"{todo_num}. [ ] Write unit tests for {module} module")
        todos.append({"id": todo_num, "type": "test", "module": module})
        todo_num += 1
    
    print(f"{todo_num}. [ ] Write integration tests for API endpoints")
    todos.append({"id": todo_num, "type": "test", "category": "integration"})
    todo_num += 1
    
    print(f"{todo_num}. [ ] Write end-to-end tests for user workflows")
    todos.append({"id": todo_num, "type": "test", "category": "e2e"})
    todo_num += 1
    
    print(f"{todo_num}. [ ] Achieve >80% code coverage")
    todos.append({"id": todo_num, "type": "qa", "metric": "coverage"})
    todo_num += 1
    
    # Phase 3: Integration
    print("\n## Phase 3: Integration (60-80%)")
    print("-" * 60)
    
    integrations = [
        ("Node-RED", "Complete Node-RED bridge implementation"),
        ("ReDB", "Complete ReDB database integration"),
        ("Cryptex", "Complete Cryptex file structure system"),
        ("Fire Marshal", "Complete Fire Marshal orchestration"),
        ("MCP Translator", "Complete MCP server functionality"),
    ]
    
    for name, desc in integrations:
        print(f"{todo_num}. [ ] {desc}")
        todos.append({"id": todo_num, "type": "integration", "component": name})
        todo_num += 1
    
    # Phase 4: Data Pipeline
    print("\n## Phase 4: Data Pipeline (80-90%)")
    print("-" * 60)
    
    pipeline_tasks = [
        "Implement BloodHound JSON data extraction",
        "Implement data transformation pipeline",
        "Implement data validation",
        "Implement error handling and recovery",
        "Implement data streaming",
    ]
    
    for task in pipeline_tasks:
        print(f"{todo_num}. [ ] {task}")
        todos.append({"id": todo_num, "type": "pipeline", "task": task})
        todo_num += 1
    
    # Phase 5: Polish & Deployment (90-100%)
    print("\n## Phase 5: Polish & Deployment (90-100%)")
    print("-" * 60)
    
    polish_tasks = [
        "Complete API documentation",
        "Write user guide",
        "Create installation guide",
        "Add performance benchmarks",
        "Security audit",
        "Create Windows installer (MSI)",
        "Create Windows installer (EXE)",
        "Create Linux packages",
        "Create macOS packages",
        "Set up CI/CD pipeline",
        "Create release notes",
        "Final QA testing",
        "User acceptance testing",
    ]
    
    for task in polish_tasks:
        print(f"{todo_num}. [ ] {task}")
        todos.append({"id": todo_num, "type": "polish", "task": task})
        todo_num += 1
    
    # Summary
    print("\n" + "=" * 60)
    print(f"\n📊 Summary:")
    print(f"   Total TODOs: {todo_num - 1}")
    print(f"   Implementation: {len([t for t in todos if t.get('type') == 'implementation'])}")
    print(f"   Testing: {len([t for t in todos if t.get('type') == 'test'])}")
    print(f"   Integration: {len([t for t in todos if t.get('type') == 'integration'])}")
    print(f"   Pipeline: {len([t for t in todos if t.get('type') == 'pipeline'])}")
    print(f"   Polish: {len([t for t in todos if t.get('type') == 'polish'])}")
    
    # Save to file
    with open("TODO.md", "w") as f:
        f.write("# BloodSniffer TODO List\n\n")
        f.write("Generated comprehensive TODO list for 1% to 100% completion.\n\n")
        f.write(f"Total Items: {todo_num - 1}\n\n")
        f.write(json.dumps(todos, indent=2))
    
    print(f"\n✅ TODO list saved to TODO.md")
    
    return todos

if __name__ == "__main__":
    generate_todos()


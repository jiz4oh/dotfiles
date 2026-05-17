---
name: rigorous-engineering
description: High-standard code refactoring and logic optimization. Use when performing code changes that require strict preservation of existing logic, multiple layers of validation, and comprehensive dependency analysis.
---

# Rigorous Engineering Standards

This skill enforces a set of senior engineering mandates for code modification, refactoring, and optimization.

## Core Mandates

### 1. Business Logic Preservation
- **Strict Adherence:** Maintain the original core business logic.
- **Logs & Comments:** NEVER delete or modify existing logs or comments without an explicit, documented reason (e.g., they are demonstrably incorrect).
- **Justified Adjustments:** Only adjust logic if it is clearly defective or severely unreasonable.

### 2. Triple-Layer Logic Validation
For *every* proposed code change, perform three independent self-logic validations:
1. **Structural Validation:** Confirm the change is syntactically correct and fits the local architectural pattern.
2. **Behavioral Validation:** Trace the execution path to ensure it handles all edge cases and matches the intended outcome.
3. **Integration Validation:** Verify that the change doesn't introduce side effects in the immediate context.

### 3. Upstream & Downstream Analysis
Before any implementation:
- **Map Call Chains:** Use `grep_search` and `codebase_investigator` to find all upstream callers and downstream dependencies.
- **Dependency Integrity:** Ensure the entire test calling chain remains valid and effective after the change.
- **API Consistency:** Do not break existing public interfaces or internal contracts.

### 4. Concise & Elegant Design
- **Abstractions:** Use reasonable design patterns and abstractions to improve code reuse and maintainability.
- **Scalability:** Design for future extension without over-engineering (avoid "just-in-case" logic).
- **Clarity:** Prioritize readability over cleverness.

## Workflow Guide

### Research Phase
1. Identify the target code block.
2. Search for all references using `grep_search` to map dependencies.
3. Read upstream callers to understand the expected behavior and data types.

### Strategy Phase
1. Draft the change.
2. Perform the **Triple-Layer Logic Validation**.
3. If the change impacts callers, update the strategy to include those files.

### Execution Phase
1. Apply the change using `replace` for surgical edits.
2. Validate with automated tests.
3. Perform a final manual trace of the logic to confirm no "hallucination optimizations" occurred.

# Copilot Instructions - Universal Software Engineering Template

- This document defines universal engineering principles.  
- If a file named `project-instructions.md` exists in the same folder as this file, follow it in addition to this file for project-specific rules, architecture, and domain context.  
- If a conflict arises between these files, the project-specific instructions take precedence.

## Communication Protocol

- Address the user directly with the title "Desarrollador"

---

## Architecture Guidelines

- Clear separation of concerns
- Business logic isolated from infrastructure and I/O
- No business logic in interface/delivery layers
- Explicit data flow between layers/modules
- Stateless services when possible
- Dependencies flow inward (core does not depend on outer layers)
- High cohesion, low coupling
- Well-defined layers with clear responsibilities
- Abstractions appropriate to complexity level

---

## Development Principles

### SOLID Principles
- Single Responsibility
- Open/Closed
- Liskov Substitution
- Interface Segregation
- Dependency Inversion

### Core Practices

- Always follow the official recommended practices, conventions, and architectural guidelines of the chosen programming languages and frameworks
- DRY � avoid duplication
- KISS � simplest solution that works
- YAGNI � no speculative features
- Principle of least astonishment
- Prefer composition over inheritance
- Favor immutability when reasonable
- Avoid known security vulnerabilities, performance pitfalls and anti-patterns

---

## Code Quality Rules

- Readability over cleverness
- Explicit over implicit behavior
- Consistency across the codebase
- Small focused functions/modules
- Meaningful naming everywhere
- Avoid hidden side effects

---

## Error Handling

- Validate inputs at system boundaries
- Fail fast on invalid state
- Separate domain/business errors from system failures
- Do not leak internal details to clients
- Provide consistent error response format

---

## Security Basics

- Never trust external input
- Validate and sanitize all inputs
- Sanitize outputs
- No secrets in source code
- Never log sensitive data
- Principle of least privilege

---

## Concurrency & Data Integrity

- Operations must be idempotent when possible
- Protect critical sections from race conditions
- Use transactions for multi-step state changes
- Avoid shared mutable state
- Explicitly handle concurrent writes and retries

---

## Testing Strategy

- Unit tests for business rules and core logic
- Integration tests for critical flows
- Avoid meaningless or trivial tests
- Focus on edge cases and failure scenarios
- Maintain test readability

---

## Performance Philosophy

- Measure before optimizing
- Prefer simple solutions first
- Avoid hidden expensive operations
- Optimize only proven bottlenecks
- Design with reasonable scalability in mind

---

## Logging & Observability

- Use structured logging
- Include contextual identifiers (request id, execution id, entity ids)
- Log at appropriate levels
- Avoid excessive noise
- Logs should support debugging and monitoring

---

## Anti-Patterns to Avoid

- God Objects
- Spaghetti Code
- Hardcoded configuration
- Magic numbers/strings
- Premature optimization
- Copy-paste programming
- Leaky abstractions
- Shotgun surgery
- Hidden side effects

### Agents — MANDATORY SKILL LOADING

**Before starting ANY task**, you MUST perform the following steps in order:

1. List the contents of `.agents/skills/` to discover all available skills.
2. Read the `SKILL.md` file of **every skill whose domain is relevant** to the current task.
3. Apply the instructions found in those files throughout the entire response.




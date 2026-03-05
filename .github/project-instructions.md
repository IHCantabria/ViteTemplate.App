# GitHub Copilot Instructions

## Code Quality Standards

### Code Style
- **Comments**: English only, explanatory (not changelog-style)
- **Functions**: Arrow functions preferred
- **Refactoring**: Prioritize readability, efficiency, and simplicity
- **Complexity**: Avoid overly complex functions or excessive line counts
- **Vue component structure**: Always follow the order: script setup, template, style. 
  - Within `<script setup>`, follow this order: imports, props, stores, data/refs, computed, methods, lifecycle hooks, watchers (comment sections accordingly with uppercase headers). If you tough any component, check this conditions and apply them if they are not being followed.
  - **Linters**: Always read eslint-rules for specific rules to follow.


### Context Understanding
- Always analyze full context before suggesting changes
- Consider component interconnections and dependencies
- Think holistically about solutions

## Project Structure Conventions

### CSS
- **Methodology**: BEM (Block Element Modifier) when applicable
- **Naming**: Follow BEM conventions for class names
- **Responsiveness**: Use media queries for different screen sizes, starting with tablet-first approach, and applying media queries for larger screens
- **Colors**: Always use colors defined in `/styles/variables/_colors.scss` and `/styles/variables/_fonts_.scss`, don't creat new colors. If its needed, ask me for permission first.

### JavaScript/TypeScript
- **Error Handling**: Use try-catch blocks in async functions
- **Configuration**: Store in `/config` folder with UPPER_SNAKE_CASE variables
- **Utilities**: Reusable functions in `/utils` folder
- **API Logic**: API interactions in `/api` folder, separated from business logic

## Comment Guidelines
- **Purpose**: Explain "why" and "what", not "when changed"
- **Volume**: Moderate - avoid over-commenting
- **Focus**: Help future developers understand intent and complex logic
- **Forbidden**: Changelog comments (e.g., "// added colour to improve previous version")

## Files Format
- Always generate LF line endings in all files


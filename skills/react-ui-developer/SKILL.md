---
name: react-ui-developer
description: Guide React UI implementation with strong engineering defaults for components, forms, queries, TypeScript, styling, accessibility, state, testing, and project structure. Use this skill whenever the user asks to build, refactor, review, or standardize React frontend code, especially in React or TypeScript apps. Default to `react-hook-form` plus `zod` for forms unless the form is truly tiny, and use this skill whenever maintainability, UI architecture, validation, or frontend consistency matters.
---

# React UI Developer

This skill helps developer agents make sound React UI decisions without reinventing the same conventions on each task.

Use the references to pick the narrow guidance that fits the task. Do not load every file by default. Read only the files that matter for the work in front of you.

If a referenced file or template contains only a TODO placeholder, stop and tell the developer that the skill draft is incomplete for that topic. Propose filling that file before relying on it for implementation guidance.

## Topic Index

- Forms: `references/FORMS.md`, `templates/FORM_TEMPLATE.md`, `templates/MULTI_SECTION_FORM_TEMPLATE.md`, `templates/CONTROLLED_FORM_TEMPLATE.md`, and `templates/FORM_FIELD_TEMPLATE.md`
- Queries and server data: `references/QUERIES.md` and `templates/QUERY_TEMPLATE.md`
- Validation and TypeScript: `references/VALIDATION_AND_TYPESCRIPT.md` and `templates/VALIDATION_AND_TYPESCRIPT_TEMPLATE.md`
- Project structure: `references/PROJECT_STRUCTURE.md` and `templates/PROJECT_STRUCTURE_TEMPLATE.md`
- Styling: `references/STYLING.md` and `templates/STYLING_TEMPLATE.md`
- State management: `references/STATE_MANAGEMENT.md` and `templates/STATE_MANAGEMENT_TEMPLATE.md`
- Accessibility: `references/ACCESSIBILITY.md` and `templates/ACCESSIBILITY_TEMPLATE.md`
- Component architecture: `references/COMPONENT_ARCHITECTURE.md` and `templates/COMPONENT_ARCHITECTURE_TEMPLATE.md`
- Performance: `references/PERFORMANCE.md` and `templates/PERFORMANCE_TEMPLATE.md`
- Testing: `references/TESTING.md` and `templates/TESTING_TEMPLATE.md`
- Design systems: `references/DESIGN_SYSTEMS.md` and `templates/DESIGN_SYSTEMS_TEMPLATE.md`
- Animations and motion: `references/ANIMATIONS.md` and `templates/ANIMATIONS_TEMPLATE.md`

## How To Use This Skill

1. Identify the narrowest topic or topics that match the task.
2. Read the matching reference file first.
3. Read the matching template file only if an example or scaffold would help.
4. If you hit a TODO-only file, surface the gap to the developer and recommend filling it.
5. Follow existing project conventions when they conflict with generic preferences.

## Boundaries

- Prefer project consistency over idealized greenfield patterns.
- Keep components understandable and easy to change.
- Treat accessibility, loading states, error states, and type safety as part of the default work.
- Avoid introducing new libraries unless the project already uses them or the change clearly justifies them.

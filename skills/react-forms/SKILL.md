---
name: react-forms
description: Build, refactor, review, or standardize UI forms in react and typescript using strong defaults.
---

# React Forms

Rules and strong defaults for forms in react.
Use `react-hook-form` plus `zod` to implement forms.
Do not use this skill if work does not involve forms.

## Core principles

- Start with real HTML form semantics: `form`, `label`, `input`, `select`, `textarea`, `button type="submit"`
  - If project has builtin standard components that wrap these, use them instead.
- Include accessibility attrbiutes `aria-*`
- Prefer uncontrolled or library-managed inputs over hand-written `useState` per field.
- Treat pending, error, and success states as part of the form
- Re-validate on the server. Client validation is for UX, not trust.

## Defaults:

- Define the form structure in zod schema
- Infer typescript type from schema with `z.infer<typeof schema>`
- `react-hook-form` for form state, registration, submission, and field-level wiring
- Use `@hookform/resolvers/zod` to connect schema to the form
- Validate on submit by default
- Displays field errors to user
- pending results disable the submit button with a loading icon

### Form schema defaults

- Use browser constraints for obvious hints only, like `type="email"`, `required`, `min`, `max`, or `minLength`
- Normalize data: trim strings, coerce numbers carefully
  - `z.string().trim().min(1, "Name is required")`
  - `z.coerce.number()` for numeric inputs that arrive as strings

### Form state and component structure

- In case of obvious repetition of form fields, use wrapper components to simplify.
- Use `FormProvider` and `useFormContext` when the form is split into nested sections.
- Use `Controller` only when a third-party input cannot work with plain `register`.

### Accessibility

- Connect each field to a visible label
- Mark invalid fields with `aria-invalid`
- Connect error text to the field with `aria-describedby` when practical
- Keep error copy close to relevant field
- Move focus to the first invalid field on submit

## View examples in templates:

- Baseline simple form: `./templates/FORM_TEMPLATE.md`
- Larger form broken down into sections: `./templates/MULTI_SECTION_FORM_TEMPLATE.md`
- Custom input that cannot be used with `react-hook-form`-s `register`: `./templates/CONTROLLED_FORM_TEMPLATE.md`

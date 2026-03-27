# Forms

Use `react-hook-form` plus `zod` as the default stack for React forms.

This is the standard choice for nearly all product forms in this skill: settings screens, profile forms, admin CRUD forms, checkout flows, onboarding, filters with submission, modal forms, and multi-section forms.

## Default Stack

- Use `react-hook-form` for form state, registration, submission, and field-level wiring.
- Use `zod` as the single validation source of truth.
- Use `@hookform/resolvers/zod` to connect the schema to the form.
- Infer TypeScript types from the schema with `z.infer<typeof schema>`.

Reach for a plain native `form` plus `FormData` only when the form is truly small and simple, usually around 1-3 fields with minimal validation and no reusable field logic. Even then, keep native semantics and accessible error handling.

## Core Principles

- Start with real HTML form semantics: `form`, `label`, `input`, `select`, `textarea`, `button type="submit"`.
- Prefer uncontrolled or library-managed inputs over hand-written `useState` per field.
- Keep validation in one schema instead of scattering rules across JSX, submit handlers, and API code.
- Validate on submit by default. Add blur or change validation only when the feedback is clearly helpful.
- Treat pending, error, and success states as part of the form, not polish to add later.
- Re-validate on the server. Client validation is for UX, not trust.

## Native Semantics Still Matter

Even when using `react-hook-form`, preserve browser behavior:

- Use explicit labels, not placeholders as labels.
- Use meaningful input types like `email`, `number`, `password`, and `date`.
- Keep `name` registration intact through `register` or `Controller`.
- Use `autoComplete` values when the browser can help.
- Prefer one submit button inside a real `form`.

`react-hook-form` is the abstraction. Native form behavior is still the foundation.

## Validation Rules

- Put business rules in Zod.
- Use browser constraints for obvious hints only, like `type="email"`, `required`, `min`, `max`, or `minLength`.
- Normalize data at the boundary: trim strings, coerce numbers carefully, convert empty strings when needed, and keep that logic close to validation or submit.
- Keep schema messages user-facing and specific.

Good defaults:

- `z.string().trim().min(1, "Name is required")`
- `z.email("Invalid email address")` when available in the project version, otherwise `z.string().email("Invalid email address")`
- `z.coerce.number()` for numeric inputs that arrive as strings

## State and Component Structure

- Keep field presentation components as dumb as possible.
- Keep schema, default values, and submit logic near the form root.
- Use `FormProvider` and `useFormContext` when the form is split into nested sections.
- Use `Controller` only when a third-party input cannot work with plain `register`.
- Do not mirror form state into local component state unless the UI truly needs separate derived behavior.
- When using shared field wrappers, prefer passing the full React Hook Form error object rather than only `error.message`, so the wrapper can own consistent error rendering and ARIA wiring.

## Submission Lifecycle

Every form should answer these questions:

- What does the user see while submission is pending?
- What happens on success?
- What happens on failure?
- Can the user double-submit?
- Is the form still recoverable after a server error?

Defaults:

- Disable submit while `isSubmitting` is true.
- Show inline field errors near the field.
- Show form-level server errors near the submit area.
- Preserve user input after failed submission unless there is a strong reason to reset.
- Reset only after confirmed success and only when that matches the flow.

## Accessibility

- Connect each field to a visible label.
- Mark invalid fields with `aria-invalid`.
- Connect error text to the field with `aria-describedby` when practical.
- Keep error copy close to the relevant field.
- Move focus to the first invalid field on submit when the library flow does not already produce a clear experience.
- Do not disable submit forever just because the form is currently invalid; prefer allowing submit and showing actionable errors unless the interaction would be actively harmful.

## When To Avoid Extra Complexity

Do not introduce complex abstractions too early.

- Start with one form component for small and medium forms.
- Extract reusable field wrappers only after repeated patterns appear.
- Do not build a local form framework unless the codebase already has one.

## Common Mistakes

- Using `useState` for every field by default
- Accidentally mixing controlled and uncontrolled input behavior
- Splitting validation rules across too many layers
- Hiding errors far from the relevant field
- Using placeholders instead of labels
- Forgetting pending and server error states
- Over-validating on every keystroke
- Using `Controller` everywhere instead of only where needed

## Decision Rules

- Small, simple form: native `form` with `FormData` is acceptable
- Most product forms: `react-hook-form` plus `zod`
- Multi-section or nested form: `react-hook-form` plus `zod` plus `FormProvider`
- Custom controlled widget: `react-hook-form` plus `Controller`

## Templates

- Baseline form: `templates/FORM_TEMPLATE.md`
- Multi-section form: `templates/MULTI_SECTION_FORM_TEMPLATE.md`
- Controlled custom input form: `templates/CONTROLLED_FORM_TEMPLATE.md`
- Reusable form field pattern: `templates/FORM_FIELD_TEMPLATE.md`

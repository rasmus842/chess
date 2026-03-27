# Validation and TypeScript

Use `zod` as the default validation layer and derive TypeScript types from the schema instead of maintaining parallel interfaces by hand.

This file complements `references/FORMS.md`. For forms, the default combination is `react-hook-form` plus `zod`. For non-form inputs, parsing, URL params, API payloads, and server boundaries, the same principle still applies: validate data at the edge and derive types from the validator.

## Default Rules

- Make the schema the source of truth.
- Infer types from the schema with `z.infer<typeof schema>`.
- Parse and normalize data at boundaries, not deep inside render code.
- Keep validation messages clear and user-facing when they are shown in the UI.
- Prefer explicit schema composition over scattered ad hoc checks.

## Source of Truth

Do not create a hand-written TypeScript type and a separate validation shape that can drift.

Prefer this:

```ts
const userSchema = z.object({
  name: z.string().trim().min(1, "Name is required"),
  email: z.string().trim().email("Invalid email address"),
});

type User = z.infer<typeof userSchema>;
```

Avoid this unless there is a strong reason:

```ts
type User = {
  name: string;
  email: string;
};

const userSchema = z.object({
  name: z.string(),
  email: z.string(),
});
```

Two sources of truth drift over time. One source stays coherent.

## Boundary Parsing

Validate where untrusted or loosely typed data enters the system.

Common boundaries:

- form submission values
- API responses
- API request payloads
- URL search params
- route params
- local storage or session storage
- feature-flag payloads

Rules:

- Parse unknown data as close to the boundary as possible.
- Convert external data into trusted internal types before the rest of the code consumes it.
- Keep coercion and normalization near the schema.

## Normalization Rules

Normalize input once instead of forcing every caller to remember formatting details.

Good defaults:

- trim text input before applying required checks
- coerce numbers only when the UI naturally produces strings
- convert empty strings to `undefined` or `null` only when the domain model needs that distinction
- keep date parsing explicit and consistent

Prefer predictable transforms over clever implicit behavior.

## Zod Patterns To Prefer

- required text: `z.string().trim().min(1, "Field is required")`
- email: `z.string().trim().email("Invalid email address")`
- integer number from form input: `z.coerce.number().int()`
- optional text with cleanup: `z.string().trim().optional()` when an empty string is acceptable as a real empty string, otherwise preprocess it deliberately
- enums for known option sets instead of free-form strings
- nested objects for grouped UI state and API payloads

Use `refine` and `superRefine` for business rules that depend on multiple fields, but do not reach for them when a simpler schema shape would express the rule clearly.

## Form-Specific Guidance

When used with `react-hook-form`:

- use `zodResolver(schema)`
- infer form values from the schema
- keep `defaultValues` aligned with the schema shape
- use schema messages as the primary field error copy
- keep submit handlers typed with the inferred type

If the form contains nested sections, model the schema with nested objects instead of flattening names just to simplify field registration.

## TypeScript Guidance

- Prefer narrow, domain-specific types inferred from schemas.
- Avoid `any` for parsed external data.
- Use `unknown` for untrusted inputs, then parse.
- Keep component props focused on UI needs, not raw backend shapes, unless the component really is the boundary.
- Derive helper types from schemas and form values instead of copying the same shape into multiple files.

## Error Modeling

Distinguish between:

- field validation errors the user can fix immediately
- form-level errors such as authentication or network failures
- programmer errors that should fail loudly in development

Do not collapse all three into a single vague error string.

## Common Mistakes

- writing the same shape as both a TypeScript type and a Zod schema
- validating too late, after the data has already spread through the app
- using `any` around fetch responses or form payloads
- putting normalization in random event handlers instead of the schema boundary
- using complex `refine` logic where a clearer schema shape would work
- letting UI components know too much about raw API or storage formats

## Decision Rules

- user-entered form data: `react-hook-form` plus `zod`
- API response or request payload: parse with `zod` at the fetch boundary
- route params and search params: parse with `zod` before use
- shared domain shape: define the schema once, infer the types from it

## Templates

- Form validation baseline: `templates/FORM_TEMPLATE.md`
- Shared validation and parsing pattern: `templates/VALIDATION_AND_TYPESCRIPT_TEMPLATE.md`
- Reusable field rendering pattern: `templates/FORM_FIELD_TEMPLATE.md`

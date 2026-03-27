# Reusable Form Field Template

Use this pattern when the project needs a reusable field abstraction that removes repeated label, input ID, hint ID, error ID, and ARIA wiring.

What it demonstrates:

- a reusable `FormField` that wraps the label and input together
- `name` as the source for `id`, `htmlFor`, hint ID, and error ID
- consistent hint and error wiring through ARIA attributes
- reducing repetition without inventing a large local form framework

```tsx
import { InputHTMLAttributes } from "react";
import { FieldError, FieldValues, Path, UseFormRegister, useForm } from "react-hook-form";
import { z } from "zod";
import { zodResolver } from "@hookform/resolvers/zod";

const teamSchema = z.object({
  teamName: z.string().trim().min(1, "Team name is required"),
  billingEmail: z.string().trim().email("Invalid billing email"),
});

type TeamFormValues = z.infer<typeof teamSchema>;

type FormFieldProps<TFieldValues extends FieldValues> = {
  name: Path<TFieldValues>;
  label: string;
  register: UseFormRegister<TFieldValues>;
  error?: FieldError;
  hint?: string;
} & Omit<InputHTMLAttributes<HTMLInputElement>, "name">;

function FormField<TFieldValues extends FieldValues>({
  name,
  label,
  register,
  error,
  hint,
  ...inputProps
}: FormFieldProps<TFieldValues>) {
  const id = String(name).replace(/\./g, "-");
  const hintId = hint ? `${id}-hint` : undefined;
  const errorId = error ? `${id}-error` : undefined;
  const describedBy = [hintId, errorId].filter(Boolean).join(" ") || undefined;

  return (
    <div>
      <label htmlFor={id}>{label}</label>
      {hint ? <p id={hintId}>{hint}</p> : null}

      <input
        id={id}
        placeholder={inputProps.placeholder}
        aria-invalid={error ? "true" : "false"}
        aria-describedby={describedBy}
        {...register(name)}
        {...inputProps}
      />

      {error?.message ? <p id={errorId}>{error.message}</p> : null}
    </div>
  );
}

export function TeamSettingsForm() {
  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
  } = useForm<TeamFormValues>({
    resolver: zodResolver(teamSchema),
    defaultValues: {
      teamName: "",
      billingEmail: "",
    },
  });

  const onSubmit = async (values: TeamFormValues) => {
    await fetch("/api/team-settings", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(values),
    });
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)} noValidate>
      <FormField
        name="teamName"
        label="Team name"
        register={register}
        hint="Visible to all workspace members."
        error={errors.teamName}
        placeholder="Acme Design"
      />

      <FormField
        name="billingEmail"
        label="Billing email"
        register={register}
        error={errors.billingEmail}
        type="email"
        placeholder="billing@example.com"
      />

      <button type="submit" disabled={isSubmitting}>
        {isSubmitting ? "Saving..." : "Save settings"}
      </button>
    </form>
  );
}
```

Notes:

- Use `name` as the single source for field wiring whenever possible.
- This level of abstraction is good for standard text-like inputs that share the same rendering shape.
- Keep `Controller`, schema, submit logic, and custom widget integration at the form level.
- If the project needs `textarea`, `select`, or custom components, extend the pattern carefully instead of forcing every field through one rigid API.

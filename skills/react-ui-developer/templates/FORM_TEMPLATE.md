# Form Template

Use this as the default starting point for a standard product form.

What it demonstrates:

- `react-hook-form` plus `zod`
- schema-derived TypeScript types
- default values
- accessible labels and inline errors
- pending submit state
- form-level server error handling

```tsx
import { useState } from "react";
import { useForm } from "react-hook-form";
import { z } from "zod";
import { zodResolver } from "@hookform/resolvers/zod";

const profileSchema = z.object({
  name: z.string().trim().min(1, "Name is required"),
  email: z.string().trim().email("Invalid email address"),
  age: z.coerce.number().int().min(18, "Must be 18 or older"),
});

type ProfileFormValues = z.infer<typeof profileSchema>;

export function ProfileForm() {
  const [serverError, setServerError] = useState<string | null>(null);

  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
  } = useForm<ProfileFormValues>({
    resolver: zodResolver(profileSchema),
    defaultValues: {
      name: "",
      email: "",
      age: 18,
    },
    mode: "onSubmit",
  });

  const onSubmit = async (values: ProfileFormValues) => {
    setServerError(null);

    const response = await fetch("/api/profile", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(values),
    });

    if (!response.ok) {
      setServerError("Unable to save changes. Please try again.");
      return;
    }
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)} noValidate>
      <div>
        <label htmlFor="name">Name</label>
        <input
          id="name"
          autoComplete="name"
          aria-invalid={errors.name ? "true" : "false"}
          {...register("name")}
        />
        {errors.name ? <p>{errors.name.message}</p> : null}
      </div>

      <div>
        <label htmlFor="email">Email</label>
        <input
          id="email"
          type="email"
          autoComplete="email"
          aria-invalid={errors.email ? "true" : "false"}
          {...register("email")}
        />
        {errors.email ? <p>{errors.email.message}</p> : null}
      </div>

      <div>
        <label htmlFor="age">Age</label>
        <input
          id="age"
          type="number"
          inputMode="numeric"
          aria-invalid={errors.age ? "true" : "false"}
          {...register("age")}
        />
        {errors.age ? <p>{errors.age.message}</p> : null}
      </div>

      {serverError ? <p>{serverError}</p> : null}

      <button type="submit" disabled={isSubmitting}>
        {isSubmitting ? "Saving..." : "Save"}
      </button>
    </form>
  );
}
```

Notes:

- Keep the schema and type together.
- Prefer `mode: "onSubmit"` unless earlier feedback is clearly helpful.
- Add browser hints like `type` and `autoComplete`, but keep business rules in Zod.
- Add `noValidate` when the product should rely on custom validation messaging instead of browser popups.

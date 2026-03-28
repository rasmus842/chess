# Multi-Section Form Template

Use this pattern when the form is large enough to split into sections but still belongs to one submit flow.

What it demonstrates:

- `FormProvider` and `useFormContext`
- one schema and one submit boundary
- nested sections without prop drilling
- field components that stay presentational

```tsx
import { FormProvider, useForm, useFormContext } from "react-hook-form";
import { z } from "zod";
import { zodResolver } from "@hookform/resolvers/zod";

const accountSchema = z.object({
  profile: z.object({
    firstName: z.string().trim().min(1, "First name is required"),
    lastName: z.string().trim().min(1, "Last name is required"),
  }),
  contact: z.object({
    email: z.string().trim().email("Invalid email address"),
    phone: z.string().trim().min(1, "Phone is required"),
  }),
});

type AccountFormValues = z.infer<typeof accountSchema>;

export function AccountForm() {
  const methods = useForm<AccountFormValues>({
    resolver: zodResolver(accountSchema),
    defaultValues: {
      profile: {
        firstName: "",
        lastName: "",
      },
      contact: {
        email: "",
        phone: "",
      },
    },
  });

  const onSubmit = async (values: AccountFormValues) => {
    await fetch("/api/account", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(values),
    });
  };

  return (
    <FormProvider {...methods}>
      <form onSubmit={methods.handleSubmit(onSubmit)} noValidate>
        <ProfileSection />
        <ContactSection />

        <button type="submit" disabled={methods.formState.isSubmitting}>
          {methods.formState.isSubmitting ? "Saving..." : "Save account"}
        </button>
      </form>
    </FormProvider>
  );
}

function ProfileSection() {
  const {
    register,
    formState: { errors },
  } = useFormContext<AccountFormValues>();

  return (
    <section>
      <h2>Profile</h2>

      <label htmlFor="firstName">First name</label>
      <input
        id="firstName"
        aria-invalid={errors.profile?.firstName ? "true" : "false"}
        {...register("profile.firstName")}
      />
      {errors.profile?.firstName ? (
        <p>{errors.profile.firstName.message}</p>
      ) : null}

      <label htmlFor="lastName">Last name</label>
      <input
        id="lastName"
        aria-invalid={errors.profile?.lastName ? "true" : "false"}
        {...register("profile.lastName")}
      />
      {errors.profile?.lastName ? (
        <p>{errors.profile.lastName.message}</p>
      ) : null}
    </section>
  );
}

function ContactSection() {
  const {
    register,
    formState: { errors },
  } = useFormContext<AccountFormValues>();

  return (
    <section>
      <h2>Contact</h2>

      <label htmlFor="accountEmail">Email</label>
      <input
        id="accountEmail"
        type="email"
        aria-invalid={errors.contact?.email ? "true" : "false"}
        {...register("contact.email")}
      />
      {errors.contact?.email ? <p>{errors.contact.email.message}</p> : null}

      <label htmlFor="phone">Phone</label>
      <input
        id="phone"
        aria-invalid={errors.contact?.phone ? "true" : "false"}
        {...register("contact.phone")}
      />
      {errors.contact?.phone ? <p>{errors.contact.phone.message}</p> : null}
    </section>
  );
}
```

Notes:

- Keep one form root, one schema, and one submit handler.
- Use sections to organize UI, not to split ownership of validation.
- Reach for this pattern before inventing a custom form abstraction.

# Controlled Input Form Template

Use this when the form includes a third-party or custom input that cannot be wired with plain `register`.

What it demonstrates:

- `Controller` for controlled widgets
- `react-hook-form` still owning the full form
- keeping `Controller` local to the fields that need it

```tsx
import { Controller, useForm } from "react-hook-form";
import { z } from "zod";
import { zodResolver } from "@hookform/resolvers/zod";

const scheduleSchema = z.object({
  title: z.string().trim().min(1, "Title is required"),
  publishAt: z.string().min(1, "Publish date is required"),
});

type ScheduleFormValues = z.infer<typeof scheduleSchema>;

type DatePickerProps = {
  value: string;
  onChange: (value: string) => void;
  onBlur: () => void;
  invalid?: boolean;
};

function DatePicker({ value, onChange, onBlur, invalid }: DatePickerProps) {
  return (
    <input
      type="datetime-local"
      value={value}
      onChange={(event) => onChange(event.target.value)}
      onBlur={onBlur}
      aria-invalid={invalid ? "true" : "false"}
    />
  );
}

export function ScheduleForm() {
  const {
    register,
    control,
    handleSubmit,
    formState: { errors, isSubmitting },
  } = useForm<ScheduleFormValues>({
    resolver: zodResolver(scheduleSchema),
    defaultValues: {
      title: "",
      publishAt: "",
    },
  });

  const onSubmit = async (values: ScheduleFormValues) => {
    await fetch("/api/schedule", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(values),
    });
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)} noValidate>
      <label htmlFor="title">Title</label>
      <input
        id="title"
        aria-invalid={errors.title ? "true" : "false"}
        {...register("title")}
      />
      {errors.title ? <p>{errors.title.message}</p> : null}

      <label htmlFor="publishAt">Publish at</label>
      <Controller
        name="publishAt"
        control={control}
        render={({ field }) => (
          <DatePicker
            value={field.value}
            onChange={field.onChange}
            onBlur={field.onBlur}
            invalid={Boolean(errors.publishAt)}
          />
        )}
      />
      {errors.publishAt ? <p>{errors.publishAt.message}</p> : null}

      <button type="submit" disabled={isSubmitting}>
        {isSubmitting ? "Scheduling..." : "Schedule"}
      </button>
    </form>
  );
}
```

Notes:

- Do not use `Controller` for ordinary text inputs that work with `register`.
- Keep the controlled bridge narrow and local.
- The rest of the form should still follow the standard `react-hook-form` plus `zod` pattern.

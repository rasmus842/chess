import type { FormEventHandler, InputHTMLAttributes, ReactNode } from "react";

type FieldProps = {
  label: string;
  error?: string;
  description?: string;
} & InputHTMLAttributes<HTMLInputElement>;

type AuthFormProps = {
  onSubmit: FormEventHandler<HTMLFormElement>;
  submitLabel: string;
  isSubmitting?: boolean;
  submitDisabled?: boolean;
  error?: string | null;
  success?: string | null;
  children: ReactNode;
};

export function AuthField({ label, error, description, id, className, ...inputProps }: FieldProps) {
  const inputId = id ?? inputProps.name;
  const messageId = error ? `${inputId}-error` : description ? `${inputId}-description` : undefined;

  return (
    <label className="block" htmlFor={inputId}>
      <span className="mb-2 block text-sm font-medium tracking-[0.02em] text-[#35291d]">{label}</span>
      <input
        {...inputProps}
        aria-describedby={messageId}
        aria-invalid={error ? true : undefined}
        id={inputId}
        className={[
          "w-full rounded-2xl border px-4 py-3 text-[#20170f] outline-none transition placeholder:text-[#9b8b78]",
          error
            ? "border-red-300 bg-red-50/70 focus:border-red-500"
            : "border-[#d8cab6] bg-[#fffdf9] focus:border-[#9f845f] focus:bg-white",
          className,
        ]
          .filter(Boolean)
          .join(" ")}
      />
      {error ? (
        <span className="mt-2 block text-sm text-red-700" id={`${inputId}-error`}>
          {error}
        </span>
      ) : description ? (
        <span className="mt-2 block text-sm text-[#7b6d5d]" id={`${inputId}-description`}>
          {description}
        </span>
      ) : null}
    </label>
  );
}

export default function AuthForm({
  onSubmit,
  submitLabel,
  isSubmitting = false,
  submitDisabled = false,
  error,
  success,
  children,
}: AuthFormProps) {
  return (
    <form className="space-y-5" noValidate onSubmit={onSubmit}>
      {children}

      <div aria-live="polite" className="min-h-6">
        {error ? (
          <p className="rounded-2xl border border-red-200 bg-red-50/80 px-4 py-3 text-sm text-red-700">
            {error}
          </p>
        ) : null}
        {success ? (
          <p className="rounded-2xl border border-emerald-200 bg-emerald-50/80 px-4 py-3 text-sm text-emerald-800">
            {success}
          </p>
        ) : null}
      </div>

      <button
        className="w-full rounded-2xl bg-[linear-gradient(135deg,#2f2418,#19110b)] px-4 py-3 text-sm font-semibold tracking-[0.03em] text-[#f8f2e8] transition hover:brightness-110 disabled:cursor-not-allowed disabled:opacity-70"
        disabled={isSubmitting || submitDisabled}
        type="submit"
      >
        {submitLabel}
      </button>
    </form>
  );
}

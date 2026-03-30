import { useState } from "react";
import { zodResolver } from "@hookform/resolvers/zod";
import { useForm } from "react-hook-form";
import { useNavigate } from "react-router-dom";
import { z } from "zod";
import AuthForm, { AuthField } from "@/components/auth/AuthForm";
import AuthLayout from "@/components/auth/AuthLayout";

const verifySchema = z.object({
  username: z.string().trim().min(1, "Username is required."),
  email: z.string().trim().min(1, "Email is required.").email("Enter a valid email address."),
  code: z.string().trim().min(1, "Verification code is required."),
});

type VerifyFormValues = z.infer<typeof verifySchema>;

export default function VerifyPage() {
  const navigate = useNavigate();
  const [error, setError] = useState<string | null>(null);
  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
  } = useForm<VerifyFormValues>({
    defaultValues: {
      username: "",
      email: "",
      code: "",
    },
    resolver: zodResolver(verifySchema),
  });

  const onSubmit = async (values: VerifyFormValues) => {
    setError(null);

    try {
      const response = await fetch("/api/auth/verify", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify(values),
      });

      if (response.ok) {
        navigate("/");
        return;
      }

      if (response.status >= 400 && response.status < 500) {
        setError("Invalid verification code.");
        return;
      }

      throw new Error("Unable to verify right now.");
    } catch (submissionError) {
      setError(
        submissionError instanceof Error ? submissionError.message : "Unable to verify right now.",
      );
    }
  };

  return (
    <AuthLayout title="Verify">
      <AuthForm
        error={error}
        isSubmitting={isSubmitting}
        onSubmit={handleSubmit(onSubmit)}
        submitLabel={isSubmitting ? "Loading..." : "Verify"}
      >
        <AuthField
          autoComplete="username"
          error={errors.username?.message}
          label="Username"
          {...register("username")}
          type="text"
        />
        <AuthField
          autoComplete="email"
          error={errors.email?.message}
          label="Email"
          {...register("email")}
          type="email"
        />
        <AuthField
          error={errors.code?.message}
          inputMode="numeric"
          label="Verification code"
          {...register("code")}
          type="text"
        />
      </AuthForm>
    </AuthLayout>
  );
}

import { useState } from "react";
import { zodResolver } from "@hookform/resolvers/zod";
import { useForm } from "react-hook-form";
import { useNavigate } from "react-router-dom";
import { z } from "zod";
import AuthForm, { AuthField } from "@/components/auth/AuthForm";
import AuthLayout from "@/components/auth/AuthLayout";

const loginSchema = z.object({
  identity: z.string().trim().min(1, "Enter a username or email."),
});

type LoginFormValues = z.infer<typeof loginSchema>;

export default function LoginPage() {
  const navigate = useNavigate();
  const [error, setError] = useState<string | null>(null);
  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
  } = useForm<LoginFormValues>({
    defaultValues: {
      identity: "",
    },
    resolver: zodResolver(loginSchema),
  });

  const onSubmit = async (values: LoginFormValues) => {
    setError(null);

    try {
      const response = await fetch("/api/auth/login", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify(values),
      });

      if (!response.ok) {
        throw new Error("Unable to log in right now.");
      }

      navigate("/auth/verify");
    } catch (submissionError) {
      setError(
        submissionError instanceof Error ? submissionError.message : "Unable to log in right now.",
      );
    }
  };

  return (
    <AuthLayout title="Login">
      <AuthForm
        error={error}
        isSubmitting={isSubmitting}
        onSubmit={handleSubmit(onSubmit)}
        submitLabel={isSubmitting ? "Loading..." : "Login"}
      >
        <AuthField
          autoComplete="username"
          error={errors.identity?.message}
          label="Username or email"
          {...register("identity")}
          type="text"
        />
      </AuthForm>
    </AuthLayout>
  );
}

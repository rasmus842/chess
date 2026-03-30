import { useState } from "react";
import { zodResolver } from "@hookform/resolvers/zod";
import { useForm } from "react-hook-form";
import { useNavigate } from "react-router-dom";
import { z } from "zod";
import AuthForm, { AuthField } from "@/components/auth/AuthForm";
import AuthLayout from "@/components/auth/AuthLayout";

const signupSchema = z.object({
  username: z.string().trim().min(1, "Username is required."),
  email: z.string().trim().min(1, "Email is required.").email("Enter a valid email address."),
});

type SignupFormValues = z.infer<typeof signupSchema>;

export default function SignupPage() {
  const navigate = useNavigate();
  const [error, setError] = useState<string | null>(null);
  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
  } = useForm<SignupFormValues>({
    defaultValues: {
      username: "",
      email: "",
    },
    resolver: zodResolver(signupSchema),
  });

  const onSubmit = async (values: SignupFormValues) => {
    setError(null);

    try {
      const response = await fetch("/api/auth/signup", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify(values),
      });

      if (!response.ok) {
        throw new Error("Unable to sign up right now.");
      }

      navigate("/auth/verify");
    } catch (submissionError) {
      setError(
        submissionError instanceof Error ? submissionError.message : "Unable to sign up right now.",
      );
    }
  };

  return (
    <AuthLayout title="Sign-up">
      <AuthForm
        error={error}
        isSubmitting={isSubmitting}
        onSubmit={handleSubmit(onSubmit)}
        submitLabel={isSubmitting ? "Loading..." : "Sign up"}
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
      </AuthForm>
    </AuthLayout>
  );
}

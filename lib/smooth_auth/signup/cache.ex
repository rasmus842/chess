defmodule SmoothAuth.Signup.Cache do
  alias SmoothAuth.Signup.{Request, VerificationCode}

  @callback verify_not_exists(Request.t()) :: :ok | {:error, :duplicate}

  @callback get_by_email(String.t()) ::
              {:ok, {Request.t(), VerificationCode.code()}} | {:error, :not_found}

  @callback put(Request.t(), VerificationCode.code()) :: :ok

  @callback delete_by_email(String.t()) :: :ok

  @callback delete_all([String.t()]) :: :ok
end

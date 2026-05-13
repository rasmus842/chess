defmodule SmoothAuth.Signup.Cache do
  alias SmoothAuth.Signup.{Request, VerificationCode}

  @callback verify_not_exists(Request.t()) :: :ok | {:error, :duplicate}

  @callback get_existing(Request.t()) :: {:ok, {Request.t(), VerificationCode}} | {:error, :not_found}

  @callback put(Request.t(), VerificationCode) :: :ok

  @callback delete(Request.t()) :: :ok

  @callback delete_all([Request.t()]) :: :ok
end

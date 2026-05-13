defmodule SmoothAuth.Backend.Local.Signup do
  @moduledoc """
  Holds session and signup request data in a a GenServer process state as two maps
  """

  alias SmoothAuth.Signup.Request
  alias SmoothAuth.Signup.Verification
  alias SmoothAuth.Signup.VerificationCode
  alias SmoothAuth.Signup.CacheAdapter, as: SignupCache
  alias SmoothAuth.Backend.Local.Accounts
  
  @behaviour SmoothAuth.Signup.Service

  @impl true
  def new_signup(request = %Request{}) do
    with :ok <- SignupCache.verify_not_exists(request),
         code <- VerificationCode.generate() do
      {:ok, code}
    else
      {:error, :duplicate} -> {:error, :duplicate_signup}
    end
  end

  @impl true
  def verify_signup(%Verification{
        request: req,
        code: code
      }) do
    with {:ok, {^req, correct_code}} <- SignupCache.get_existing(req),
         true <- code === correct_code,
         {:ok, user} <- Accounts.create_new_account(req) do
      {:ok, user}
    else
      {:error, :not_found} -> {:error, :invalid_signup_request}
      false -> {:error, :invalid_verification_code}
      {:error, _validation_errors} -> {:error, :invalid_signup_request}
    end
  end
end

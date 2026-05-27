defmodule SmoothAuth.Backend.Local.Signup do
  @moduledoc false

  alias SmoothAuth.Delivery
  alias SmoothAuth.Signup.Request
  alias SmoothAuth.Signup.Verification
  alias SmoothAuth.Signup.VerificationCode
  alias SmoothAuth.Signup.CacheAdapter, as: SignupCache
  alias SmoothAuth.Backend.Local.Accounts

  @behaviour SmoothAuth.Signup.Service

  @impl true
  def new_signup(request = %Request{email: email, username: username}) do
    with :ok <- SignupCache.verify_not_exists(request),
         code <- VerificationCode.generate(),
         :ok <- SignupCache.put(request, code),
         :ok <-
           Delivery.deliver_code(email, :signup_verify_email, code, %{
             username: username
           }) do
      :ok
    else
      {:error, :duplicate} ->
        :ok

      {:error, reason} ->
        _ = SignupCache.delete_by_email(email)
        {:error, {:delivery_failed, reason}}
    end
  end

  @impl true
  def verify_signup(%Verification{
        request: req = %Request{email: email},
        code: code
      }) do
    with {:ok, {^req, correct_code}} <- SignupCache.get_by_email(email),
         true <- code === correct_code,
         {:ok, account} <- Accounts.create_new_account(req),
         :ok <- SignupCache.delete_by_email(email) do
      {:ok, account}
    else
      {:error, :not_found} -> {:error, :not_found}
      false -> {:error, :invalid_verification_code}
      {:error, _validation_errors} -> {:error, :invalid_signup_request}
    end
  end
end

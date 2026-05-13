defmodule SmoothAuth do
  @moduledoc false

  alias SmoothAuth.Subject

  @type token_bundle :: %{
          access_token: String.t(),
          refresh_token: String.t(),
          subject: Subject.t()
        }

  @config Application.compile_env(:smooth_auth, SmoothAuth)
  @backend Keyword.fetch!(@config, :backend)

  @spec request_signup(String.t(), String.t()) :: :ok | {:error, term()}
  defdelegate request_signup(email, username), to: @backend

  @spec verify_signup_code(String.t(), String.t(), String.t()) ::
          {:ok, token_bundle()} | {:error, term()}
  defdelegate verify_signup_code(email, username, code), to: @backend

  @spec request_login(String.t()) :: {:ok, :accepted} | {:error, term()}
  defdelegate request_login(email), to: @backend

  @spec verify_login_code(String.t(), String.t()) :: {:ok, token_bundle()} | {:error, term()}
  defdelegate verify_login_code(email, code), to: @backend

  @spec refresh_session(String.t()) :: {:ok, token_bundle()} | {:error, term()}
  defdelegate refresh_session(refresh_token), to: @backend

  @spec logout(String.t()) :: {:ok, :logged_out} | {:error, term()}
  defdelegate logout(refresh_token), to: @backend

  @spec authenticate(String.t()) :: {:ok, Subject.t()} | {:error, term()}
  defdelegate authenticate(access_token), to: @backend
end

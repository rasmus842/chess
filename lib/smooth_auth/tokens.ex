defmodule SmoothAuth.Tokens do
  @moduledoc """
  TODO - this is for future if token-based authentication is requires.
  For example for API-s.
  """

  alias SmoothAuth.Subject

  @type access_token :: String.t()
  @type refresh_token :: String.t()
  @type token_bundle :: %{
          access_token: access_token(),
          refresh_token: refresh_token(),
          subject: Subject.t()
        }

  @spec request_signup(String.t(), String.t()) :: :ok | {:error, term()}
  def request_signup(email, username), do: backend().request_signup(email, username)

  @spec verify_signup_code(String.t(), String.t()) :: {:ok, token_bundle()} | {:error, term()}
  def verify_signup_code(email, code), do: backend().verify_signup_code(email, code)

  @spec verify_signup_code(String.t(), String.t(), String.t()) ::
          {:ok, token_bundle()} | {:error, term()}
  def verify_signup_code(email, _username, code), do: verify_signup_code(email, code)

  @spec request_login(String.t()) :: :ok | {:ok, :accepted} | {:error, term()}
  def request_login(email), do: backend().request_login(email)

  @spec verify_login_code(String.t(), String.t()) :: {:ok, token_bundle()} | {:error, term()}
  def verify_login_code(email, code), do: backend().verify_login_code(email, code)

  @spec refresh_session(refresh_token()) :: {:ok, token_bundle()} | {:error, term()}
  def refresh_session(refresh_token), do: backend().refresh_session(refresh_token)

  @spec logout(refresh_token()) :: :ok | {:ok, :logged_out} | {:error, term()}
  def logout(refresh_token), do: backend().logout(refresh_token)

  @spec authenticate(access_token()) :: {:ok, Subject.t()} | {:error, term()}
  def authenticate(access_token), do: backend().authenticate(access_token)

  defp backend do
    :chess
    |> Application.fetch_env!(__MODULE__)
    |> Keyword.fetch!(:backend)
  end
end

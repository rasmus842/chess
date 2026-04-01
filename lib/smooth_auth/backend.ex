defmodule SmoothAuth.Backend do
  @moduledoc false

  alias SmoothAuth.Subject

  @type email :: String.t()
  @type username :: String.t()
  @type verification_code :: String.t()

  @type session_id :: String.t()

  @type session :: %{
          session_id: session_id(),
          subject: Subject.t()
        }

  @callback request_signup(email(), username()) :: :ok | {:error, term()}

  @callback verify_signup_code(email(), username(), verification_code()) ::
              {:ok, session()} | {:error, term()}

  @callback request_login(email()) :: :ok | {:error, term()}

  @callback verify_login_code(email(), verification_code()) ::
              {:ok, session()} | {:error, term()}

  @callback refresh_session(session_id()) :: {:ok, session()} | {:error, term()}

  @callback logout(session_id()) :: :ok | {:error, term()}

  @callback authenticate(session_id()) :: {:ok, Subject.t()} | {:error, term()}
end

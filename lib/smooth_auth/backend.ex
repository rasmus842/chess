defmodule SmoothAuth.Backend do
  @moduledoc false

  alias SmoothAuth.{Account, Session, Subject}
  alias SmoothAuth.Signup.{Request, Verification}

  @callback request_signup(Request.t()) :: :ok | {:error, term()}
  
  @callback verify_signup(Verification.t()) :: {:ok, Account.t()} | {:error, term()}

  @callback request_login(String.t()) :: {:ok, :accepted} | {:error, term()}
  
  @callback verify_login(String.t(), String.t()) :: {:ok, Session.t()} | {:error, term()}

  @callback refresh_session(Session.session_id()) :: {:ok, Session.t()} | {:error, term()}

  @callback logout(Session.session_id()) :: :ok | {:error, term()}

  @callback authenticate(Session.session_id()) :: {:ok, Subject.t()} | {:error, term()}

  @callback me(Session.session_id()) :: {:ok, Account.t()} | {:error, term()}
end

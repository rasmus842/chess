defmodule SmoothAuth.Backend.Local.Sessions do
  @moduledoc false

  require Logger
  alias SmoothAuth.{Account, Session, Subject}
  alias SmoothAuth.Backend.Local.InMemorySessions

  @spec create_session(Account.t()) :: {:ok, Session.t()} | {:error, term()}
  def create_session(%Account{} = account) do
    with subject <- subject_from_account(account),
         session <- new_session(subject),
         :ok <- InMemorySessions.put(session) do
      {:ok, session}
    else
      err ->
        Logger.error("Failed to create new session", account: account, error: err)
        {:error, "Failed to create session"}
    end
  end

  @spec refresh_session(String.t()) :: {:ok, Session.t()} | {:error, term()}
  def refresh_session(session_id) when is_binary(session_id) do
    with {:ok, %Session{subject: subject}} <- InMemorySessions.get(session_id),
         new_session <- new_session(subject),
         :ok <- InMemorySessions.delete(session_id),
         :ok <- InMemorySessions.put(new_session) do
      {:ok, new_session}
    else
      err ->
        Logger.error("Failed to refresh session", session_id: session_id, error: err)
        {:error, "Failed to refresh session"}
    end
  end

  @spec expire_session(String.t()) :: :ok | {:error, term()}
  def expire_session(session_id) when is_binary(session_id) do
    InMemorySessions.delete(session_id)
  end

  @spec authenticate(String.t()) :: {:ok, Subject.t()} | {:error, :not_found}
  def authenticate(session_id) when is_binary(session_id) do
    with {:ok, %Session{subject: subject}} <- InMemorySessions.get(session_id) do
      {:ok, subject}
    else
      _err -> {:error, :not_found}
    end
  end

  defp new_session(%Subject{} = subject) do
    now = current_time()

    %Session{
      session_id: generate_session_id(),
      subject: subject,
      created_at: now,
      expires_at: DateTime.add(now, session_ttl_minutes(), :minute)
    }
  end

  defp current_time() do
    DateTime.utc_now()
  end

  defp subject_from_account(%Account{id: id, email: email, username: username}) do
    %Subject{user_id: id, email: email, username: username}
  end

  defp generate_session_id do
    32
    |> :crypto.strong_rand_bytes()
    |> Base.url_encode64(padding: false)
  end

  defp config() do
    Application.fetch_env!(:smooth_auth, SmoothAuth)
  end

  defp session_ttl_minutes() do
    Keyword.fetch!(config(), :session_ttl_minutes)
  end
end

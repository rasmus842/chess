defmodule SmoothAuth do
  @moduledoc false

  @config Application.compile_env(:smooth_auth, SmoothAuth)
  @backend Keyword.fetch!(@config, :backend)

  @behaviour SmoothAuth.Backend

  @impl true
  defdelegate request_signup(request), to: @backend

  @impl true
  defdelegate verify_signup(verification), to: @backend

  @impl true
  defdelegate request_login(email), to: @backend

  @impl true
  defdelegate verify_login(email, code), to: @backend

  @impl true
  defdelegate refresh_session(session_id), to: @backend

  @impl true
  defdelegate logout(session_id), to: @backend

  @impl true
  defdelegate authenticate(session_id), to: @backend
end

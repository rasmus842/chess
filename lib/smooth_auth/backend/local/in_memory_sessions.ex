defmodule SmoothAuth.Backend.Local.InMemorySessions do
  use GenServer

  alias SmoothAuth.Session

  def start_link(_opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    {:ok, %{}}
  end

  def get(session_id) when is_binary(session_id) do
    call({:get, session_id})
  end

  def put(%Session{} = session) do
    call({:put, session})
  end

  def delete(session_id) when is_binary(session_id) do
    call({:delete, session_id})
  end

  def handle_call(params, _from, sessions) do
    {result, updated_sessions} = handle(params, sessions)
    {:reply, result, updated_sessions}
  end

  defp handle({:get, session_id}, sessions) do
    case Map.fetch(sessions, session_id) do
      {:ok, session} -> {{:ok, session}, sessions}
      :error -> {{:error, :not_found}, sessions}
    end
  end

  defp handle({:put, %Session{session_id: session_id} = session}, sessions) do
    {:ok, Map.put(sessions, session_id, session)}
  end

  defp handle({:delete, session_id}, sessions) do
    case Map.has_key?(sessions, session_id) do
      true -> {:ok, Map.delete(sessions, session_id)}
      false -> {{:error, :not_found}, sessions}
    end
  end

  defp call(params) do
    GenServer.call(__MODULE__, params)
  end
end

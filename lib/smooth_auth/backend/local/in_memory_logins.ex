defmodule SmoothAuth.Backend.Local.InMemoryLogins do
  use GenServer

  def start_link(_opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    {:ok, %{}}
  end

  def get(email) when is_binary(email) do
    call({:get, email})
  end

  def put(email, code) when is_binary(email) and is_binary(code) do
    call({:put, email, code})
  end

  def delete(email) when is_binary(email) do
    call({:delete, email})
  end

  def handle_call(params, _from, logins) do
    {result, updated_logins} = handle(params, logins)
    {:reply, result, updated_logins}
  end

  defp handle({:get, email}, logins) do
    case Map.fetch(logins, email) do
      {:ok, code} -> {{:ok, code}, logins}
      :error -> {{:error, :not_found}, logins}
    end
  end

  defp handle({:put, email, code}, logins) do
    {:ok, Map.put(logins, email, code)}
  end

  defp handle({:delete, email}, logins) do
    case Map.has_key?(logins, email) do
      true -> {:ok, Map.delete(logins, email)}
      false -> {{:error, :not_found}, logins}
    end
  end

  defp call(params) do
    GenServer.call(__MODULE__, params)
  end
end

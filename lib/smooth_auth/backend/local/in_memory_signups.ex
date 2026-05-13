defmodule SmoothAuth.Backend.Local.InMemorySignups do
  use GenServer

  @behaviour SmoothAuth.Signup.Cache

  def start_link() do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl true
  def init(:ok) do
    {:ok, %{}}
  end

  @impl true
  def verify_not_exists(request) do
    call({:verify_not_exists, request})
  end

  @impl true
  def get_existing(request) do
    call({:get_existing, request})
  end

  @impl true
  def put(request, code) do
    call({:put, request, code})
  end

  @impl true
  def delete(request) do
    call({:delete, request})
  end

  @impl true
  def delete_all(requests) do
    call({:delete_all, requests})
  end

  defp call(params) do
    GenServer.call(__MODULE__, params)
  end

  @impl true
  def handle_call(params, _from, requests) do
    {result, updated_requests} = handle(params, requests)
    {:reply, result, updated_requests}
  end

  defp handle(params, requests) do
    case params do
      {:verify_not_exists, req} when is_struct(req) ->
        case Map.get(requests, req) do
          nil -> :ok
          _code -> {:error, :duplicate_key}
        end

      {:get_existing, req} when is_struct(req) ->
        case Map.get(requests, req) do
          nil -> {:error, :not_found}
          code -> {:ok, {req, code}}
        end

      {:put, req, code} when is_struct(req) and is_binary(code) ->
        updated_requests = Map.put(requests, req, code)
        {:ok, updated_requests}

      {:delete, req} when is_struct(req) ->
        updated_requests = Map.delete(requests, req)
        {:ok, updated_requests}

      {:delete_all, req_list} when is_list(req_list) ->
        updated_requests = Map.drop(requests, req_list)
        {:ok, updated_requests}
    end
  end
end

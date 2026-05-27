defmodule SmoothAuth.Backend.Local.InMemorySignups do
  use GenServer

  @behaviour SmoothAuth.Signup.Cache

  alias SmoothAuth.Signup.Request

  def start_link(_opts \\ []) do
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
  def get_by_email(email) do
    call({:get_by_email, email})
  end

  @impl true
  def put(request, code) do
    call({:put, request, code})
  end

  @impl true
  def delete_by_email(email) do
    call({:delete_by_email, email})
  end

  @impl true
  def delete_all(emails) do
    call({:delete_all, emails})
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
      {:verify_not_exists, %Request{email: email}} ->
        case Map.get(requests, email) do
          nil -> {:ok, requests}
          {_request, _code} -> {{:error, :duplicate}, requests}
        end

      {:get_by_email, email} when is_binary(email) ->
        case Map.get(requests, email) do
          nil -> {{:error, :not_found}, requests}
          {request, code} -> {{:ok, {request, code}}, requests}
        end

      {:put, %Request{email: email} = request, code} when is_binary(code) ->
        updated_requests = Map.put(requests, email, {request, code})
        {:ok, updated_requests}

      {:delete_by_email, email} when is_binary(email) ->
        updated_requests = Map.delete(requests, email)
        {:ok, updated_requests}

      {:delete_all, emails} when is_list(emails) ->
        updated_requests = Map.drop(requests, emails)
        {:ok, updated_requests}
    end
  end
end

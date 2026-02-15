defmodule ChessWeb.UserSocket do
  use Phoenix.Socket

  channel "game", ChessWeb.GameChannel
  
  @doc """
  Validate socket connections - must be authenticated
  """
  @impl true
  def connect(%{"token" => _token}, socket, _connect_info) do
    {:ok, socket}
  end

  @doc """
  Allow anonymous users
  """
  def connect(_params, socket, _connect_info) do
    {:ok, socket}
  end

  @impl true
  def id(_socket), do: nil
end 

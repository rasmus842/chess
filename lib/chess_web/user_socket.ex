defmodule ChessWeb.UserSocket do
  use Phoenix.Socket

  channel "game:*", ChessWeb.GameChannel

  @impl true
  def connect(%{"token" => token}, socket, _connect_info) do
    case SmoothAuth.authenticate(token) do
      {:ok, subject} -> {:ok, assign(socket, :current_subject, subject)}
      {:error, _reason} -> :error
    end
  end

  @impl true
  def id(%{assigns: %{current_subject: subject}}), do: "user_socket:#{subject.user_id}"
  def id(_socket), do: nil
end

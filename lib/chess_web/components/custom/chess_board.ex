defmodule ChessWeb.Custom.ChessBoard do
  use ChessWeb, :html
  import ChessWeb.Custom.Square

  attr :pieces, :map, default: %{}

  def chess_board(assigns) do
    ~H"""
    <div class="m-8 grid grid-cols-8 grid-rows-8 overflow-auto border border-solid border-brown-500">
      <%= for row <- 8..1//-1, col <- ?a..?h do %>
        <.square row={row} col={col} piece={get_piece(@pieces, {row, col})} />
      <% end %>
    </div>
    """
  end

  defp get_piece(pieces, {row, col}) when is_map(pieces) do
    Map.get(pieces, {row, col})
  end
end

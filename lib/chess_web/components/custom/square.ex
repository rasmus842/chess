defmodule ChessWeb.Custom.Square do
  use ChessWeb, :html
  import Integer

  attr :row, :integer, required: true, values: 1..8
  attr :col, :integer, required: true, values: ?a..?h

  attr :piece, :atom,
    default: nil,
    values: [
      nil,
      :white_pawn,
      :white_rook,
      :white_knight,
      :white_bishop,
      :white_queen,
      :white_king,
      :black_pawn,
      :black_rook,
      :black_knight,
      :black_bishop,
      :black_queen,
      :black_king
    ]

  def square(assigns) do
    ~H"""
    <div
      class={[
        "sm:size-8 md:size-16 flex items-center justify-center",
        (light?(@row, @col) && "bg-green-50") || "bg-green-700"
      ]}
      data-row={@row}
      data-col={<<@col::utf8>>}
    >
      <%= if @piece do %>
        <img src={get_chess_piece(@piece)} alt="Chess piece" } />
      <% end %>
    </div>
    """
  end

  defp light?(row, col) when is_even(row) and is_odd(col), do: true
  defp light?(row, col) when is_odd(row) and is_even(col), do: true
  defp light?(_row, _col), do: false

  defp get_chess_piece(x) when is_atom(x) do
    ~p"/images/#{Atom.to_string(x) <> ".svg"}"
  end
end

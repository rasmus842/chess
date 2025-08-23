defmodule ChessWeb.Custom.ChessGame do
  use ChessWeb, :html
  import ChessWeb.Custom.ChessBoard

  def chess_game(assigns) do
    items = initial_position()

    ~H"""
    <div class="relative">
      <.chess_board pieces={items} />
    </div>
    """
  end

  defp initial_position() do
    ?a..?h
    |> Enum.flat_map(fn col ->
      1..8
      |> Enum.map(fn row -> piece_for_initial_position({row, col}) end)
    end)
    |> Map.new()
  end

  defp piece_for_initial_position(_position_key = {row, col}) do
    case key = {row, col} do
      {2, _} -> {key, :white_pawn}
      {7, _} -> {key, :black_pawn}
      {1, c} when c in [?a, ?h] -> {key, :white_rook}
      {8, c} when c in [?a, ?h] -> {key, :black_rook}
      {1, c} when c in [?b, ?g] -> {key, :white_knight}
      {8, c} when c in [?b, ?g] -> {key, :black_knight}
      {1, c} when c in [?c, ?f] -> {key, :white_bishop}
      {8, c} when c in [?c, ?f] -> {key, :black_bishop}
      {1, ?d} -> {key, :white_queen}
      {8, ?d} -> {key, :black_queen}
      {1, ?e} -> {key, :white_king}
      {8, ?e} -> {key, :black_king}
      _ -> {key, nil}
    end
  end
end

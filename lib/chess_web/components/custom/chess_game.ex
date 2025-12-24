defmodule ChessWeb.Custom.ChessGame do
  use ChessWeb, :html
  import ChessWeb.Custom.ChessBoard
  alias Chess.Game.GameState

  def chess_game(assigns) do
    ~H"""
    <div class="relative">
      <.chess_board pieces={GameState.initial_position()} />
    </div>
    """
  end
end

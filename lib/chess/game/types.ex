defmodule Chess.Game.Types do
  defmacro __using__(_opts) do
    quote do
      @type kind :: :pawn | :rook | :knight | :bishop | :queen | :king
      @type color :: :white | :black
      @type player :: color()
      @type piece :: {color(), kind()}

      @type file :: ?a | ?b | ?c | ?d | ?e | ?f | ?g | ?h
      @type rank :: 1..8
      @type cell :: {file(), rank()}
      @type board :: %{cell() => piece() | nil}

      @type game_state :: {Chess.Game.Props.t(), board()}

      @type move :: {cell(), cell()}
      @type game_action :: {game_state(), move(), player()}
      @type error :: {:error, String.t()}
    end
  end
end

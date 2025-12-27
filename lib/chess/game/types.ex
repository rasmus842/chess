defmodule Chess.Game.Types do
  @type kind :: :pawn | :rook | :knight | :bishop | :queen | :king
  @type color :: :white | :black
  @type player :: color()
  @type piece :: {color(), kind()}

  @type file :: ?a | ?b | ?c | ?d | ?e | ?f | ?g | ?h
  @type rank :: 1..8
  @type cell :: {file(), rank()}
  @type board :: %{cell() => piece() | nil}

  @type move :: {cell(), cell()}
  @type cells :: MapSet.t(cell())
  @type targets :: %{optional(cell()) => cells()}
  @type attacks :: %{optional(cell()) => cells()}
  @type error :: {:error, term()}

  @type result(t) :: {:ok, t} | error()
  @type result :: :ok | error()
end

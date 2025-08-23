defmodule ChessWeb.HomePageHTML do
  use ChessWeb, :html
  import ChessWeb.Custom.ChessGame

  embed_templates "./*"
end

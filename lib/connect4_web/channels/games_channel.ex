defmodule Connect4Web.GamesChannel do
  use Connect4Web, :channel

  alias Connect4.Game

  def join("games:" <> name, payload, socket) do
    game = Connect4.GameBackup.load(name) || Game.new()
    socket = socket
    |> assign(:game, game)
    |> assign(:name, name)
    {:ok, %{"join" => name, "game" => game}, socket}
  end
end

defmodule Connect4Web.GamesChannel do
  use Connect4Web, :channel

  alias Connect4.Game

  def join("games:" <> name, payload, socket) do
    game = Connect4.GameBackup.load(name) || Game.new()
    role = "RED"
    socket = socket
    |> assign(:game, game)
    |> assign(:name, name)
    |> assign(:role, "RED")
    {:ok, %{name: name, game: game, role: role}, socket}

  end

  def handle_in("move", %{"column_index" => column_index}, socket) do
    broadcast! socket, "update", %{ game: Game.new() }
    {:noreply, socket}
  end
end

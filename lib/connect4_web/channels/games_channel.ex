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
    game = Game.move(socket.assigns[:game], socket.assigns[:role], column_index)
    Connect4.GameBackup.save(socket.assigns[:name], game)
    socket = socket
    |> assign(:game, game)
    broadcast! socket, "update", %{ game: game }
    {:noreply, socket}
  end
end

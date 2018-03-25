defmodule Connect4Web.GamesChannel do
  use Connect4Web, :channel

  alias Connect4.Game

  def join("games:" <> name, payload, socket) do
    game = Connect4.GameBackup.load(name) || Game.new()
    socket = socket
    |> assign(:game, game)
    |> assign(:name, name)
    |> assign(:role, "RED")
    {:ok, %{"join" => name, "game" => game}, socket}
  end

  def handle_in("move", %{"column_index" => column_index}, socket) do
    IO.inspect socket.assigns[:name]
    IO.inspect socket.assigns[:role]
    IO.inspect socket.assigns[:game]
    {:noreply, socket}
  end
end

defmodule Connect4.GamesChannel do
	use Connect4Web, :channel

	alias Connect4.Game

	def join("games:" <> name, payload, socket) do
		if authorized?(payload) do
			game = Connect4.GameBackup.load(name) || Game.new()
			socket = socket
			|> assign(:game, game)
			|> assign(:name, game)
			{:ok, %{"join" => name, "game" => Game.client_view(game)}}, socket}
		else
			{:error, %{reason: "unauthorized"}}
		end
	end

	def handle_in("move", %{"role" => role, "column" => column}, socket) do
		game = Game.move(socket.assigns[:game], role, column)
		Connect4.GameBackup.save(socket.assign[:name], game)
		socket = assign(socket, :game, game)
		{:reply, {:ok, %{"game" => game}}, socket}
	end

	defp authorized?(_payload) do
		true
	end
end
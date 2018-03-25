defmodule Connect4Web.GamesChannel do
  use Connect4Web, :channel

  alias Connect4.Game

  def join("games:" <> name, _, socket) do
    state = Connect4.GameBackup.load(name)
    %{ :new_state => new_state, :role => role } = if state do
      IO.puts "here"
      role = cond do
        state.has_yellow and state.has_red -> :spectator
        state.has_yellow -> :red
        state.has_red -> :yellow
      end
      new_state = %{ game: state.game, has_yellow: true, has_red: true }
      %{ new_state: new_state, role: role }
    else
      new_state = Game.new()
      %{ new_state: new_state, role: new_state.game.turn }
    end
    socket = socket
    |> assign(:name, name)
    |> assign(:role, role)
    Connect4.GameBackup.save(name, new_state)
    {:ok, %{name: name, game: new_state.game, role: role}, socket}
  end

  def handle_in("move", %{"column_index" => column_index}, socket) do
    state = Connect4.GameBackup.load(socket.assigns[:name])
    game = Game.move(state[:game], socket.assigns[:role], column_index)
    Connect4.GameBackup.save(socket.assigns[:name], %{state | game: game})
    broadcast! socket, "update", %{ game: game }
    {:noreply, socket}
  end
end

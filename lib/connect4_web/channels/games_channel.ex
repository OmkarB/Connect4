defmodule Connect4Web.GamesChannel do
  use Connect4Web, :channel

  alias Connect4.Game

  def join("games:" <> name, _, socket) do
    state = Connect4.GameBackup.load(name)
    %{ :new_state => new_state, :role => role } = if state do
      role = cond do
        state.has_yellow and state.has_red -> :spectator
        state.has_yellow -> :red
        state.has_red -> :yellow
      end
      new_state = %{ state | has_yellow: true, has_red: true }
      %{ new_state: new_state, role: role }
    else
      new_state = Game.new()
      %{ new_state: new_state, role: new_state.game.turn }
    end
    socket = socket
    |> assign(:name, name)
    |> assign(:role, role)
    Connect4.GameBackup.save(name, new_state)
    {:ok, %{name: name, game: new_state.game, role: role, messages: new_state.messages}, socket}
  end

  def handle_in("move", %{"column_index" => column_index}, socket) do
    state = Connect4.GameBackup.load(socket.assigns[:name])
    game = Game.move(state[:game], socket.assigns[:role], column_index)
    Connect4.GameBackup.save(socket.assigns[:name], %{state | game: game})
    broadcast! socket, "update_game", %{game: game}
    {:noreply, socket}
  end

  def handle_in("msg", %{"body" => body}, socket) do
    state = Connect4.GameBackup.load(socket.assigns[:name])
    new_messages = state.messages ++ [%{role: socket.assigns[:role], body: body}]
    new_state = %{state | messages: new_messages}
    Connect4.GameBackup.save(socket.assigns[:name], new_state)
    broadcast! socket, "update_messages", %{messages: new_messages}
    {:noreply, socket}
  end
end

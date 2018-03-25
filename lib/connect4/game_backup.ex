defmodule Connect4.GameBackup do
  use Agent

  def start_link do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def save(name, game_state) do
    Agent.update __MODULE__, fn state ->
      Map.put(state, name, game_state)
    end
  end

  def load(name) do
    Agent.get __MODULE__, fn state ->
      Map.get(state, name)
    end
  end
end

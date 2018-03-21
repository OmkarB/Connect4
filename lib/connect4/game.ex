defmodule Connect4.Game do

    def new() do
      %{
        board: create_board(),
        role: 'red',
        game_over: False
      }
    end

    def create_board() do
      row = [nil, nil, nil, nil, nil, nil, nil]
      board = for i <- 0..5, do: row
    end
end
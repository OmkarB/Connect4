defmodule Connect4.Game do

    def new() do
      %{
        board: create_board(),
        role: 'red',
        winner: nil
      }
    end

    def create_board() do
      row = [nil, nil, nil, nil, nil, nil, nil]
      board = for i <- 0..5, do: row
    end

    def find_last_index(column) do
      7 - length(Enum.filter(column, fn(coin) ->
        match?({nil, _}, coin)
      end))
    end

    def move(game, role, columnIdx) do
      case Enum.at(game.board, columnIdx) do
        column ->
          row = find_last_index(column)
          List.replace_at(column, row, role)
      end
    end
end
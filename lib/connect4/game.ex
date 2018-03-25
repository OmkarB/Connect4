defmodule Connect4.Game do
  def new() do
    %{
      board: create_board(),
      turn: "RED",
      winner: nil
    }
  end

  def create_board() do
    row = [nil, nil, nil, nil, nil, nil, nil]
    board = for i <- 0..5, do: row
  end

  def move(game, role, column_index) do
    row_index_from_end = Enum.reverse(game.board)
    |> Enum.find_index(fn (row) -> !Enum.at(row, column_index) end)
    row_index = Enum.count(game.board) - 1 - row_index_from_end
    new_board = List.update_at(game.board, row_index, fn (row) -> List.replace_at(row, column_index, role) end)
    %{ game | board: new_board }
  end
end

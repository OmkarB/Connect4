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

  def find_last_index(column) do
    7 - length(Enum.filter(column, fn(coin) ->
      match?({nil, _}, coin)
    end))
  end

  def move(game, role, column_index) do
    row_index_from_end = Enum.reverse(game.board)
    |> Enum.find_index(fn (row) -> !Enum.at(row, column_index) end)
    row_index = Enum.count(game.board) - 1 - row_index_from_end
    new_board = List.update_at(game.board, row_index, fn (row) -> List.replace_at(row, column_index, role) end)
    %{ game | board: new_board }
  end

  # https://stackoverflow.com/questions/47751186/adding-item-to-list used as
  def is_four_in_row?(row, role) do
    count = row |> List.foldl(0, fn (item, acc) ->
      case {item, acc} do
        {_, 4} -> 4
        {^role, _} -> acc + 1
        _ -> 0
      end
    end)
    count == 4
  end

  def column_win?(board, role, column) do
    Enum.at(board, column) |> is_four_in_row?(role)
  end

  def row_win?(board, role, row) do
    false
  end

  def diagonal_win?(board, role, row, column) do
    flat_board = List.flatten board
    left_diagonal = Enum.take_every(flat_board, 7)
    right_diagonal = Enum.take_every(flat_board, 9)

    diagonals = left_diagonal ++ right_diagonal
    Enum.any? board, fn(row) -> is_four_in_row?(row, role) end
  end

  def is_game_over?(game, role, column, row) do
    cond do
      column_win?(game.board, role, column) ->
        true
      row_win?(game.board, role, row) ->
        true
      diagonal_win?(game.board, role, row, column) ->
        true
      true ->
        false
    end
  end
end

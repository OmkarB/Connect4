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

    def move(game, role, column_idx) do
      case Enum.at(game.board, column_idx) do
        column ->
          row = find_last_index(column)
          new_col = List.replace_at(column, row, role)
          new_game = %{game | board: List.replace_at(game.board, column_idx, new_col)}

          if is_game_over(new_game, role, new_col, row) do
            new_game = %{new_game | winner: role}
          end
    end

    # https://stackoverflow.com/questions/47751186/adding-item-to-list used as
    def is_four_in_row(row, role) do
      count = row |> List.foldl 0, fn (item, acc) ->
        case {item, acc} do
          {_, 4} -> 4
          {^role, _} -> acc + 1
          _ -> 0
        end
      end
      count == 4
    end

    def column_win?(board, role, column) do
      Enum.at(board, column) |> is_four_in_row?(role)
    end

    def row_win?(board, role, row) do
      # http://langintro.com/elixir/article2/
      flipped ->
        for i <- 0..5 do
          Enum.map(board, fn(row) ->
            if i <= 5, do: Enum.at(row, i)
          end)
        end
      Enum.at(flipped, row) |> is_four_in_row(role)
    end

    def diagonal_win?(board, role, row, column) do
      flat_board = List.flatten board
      left_diagonal = Enum.take_every(flat_board, 7)
      right_diagonal = Enum.take_every(flat_board, 9)

      diagonals = left_diagonal ++ right_diagonal
      Enun.any? board, fn(row) -> is_four_in_row?(row, role) end
    end

    def is_game_over?(game, role, column, row)
      cond do
        column_win?(board, role, column) ->
          true
        row_win?(board, role, row) ->
          true
        diagonal_win?(board, role, row, column) ->
          true
        _ ->
          false
    end

end
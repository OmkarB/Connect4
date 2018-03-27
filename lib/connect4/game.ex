defmodule Connect4.Game do
  def new() do
    turn = Enum.random([:yellow, :red])
    %{
      game: %{
        board: create_board(),
        turn: turn,
        winner: nil,
      },
      has_yellow: turn == :yellow,
      has_red: turn == :red,
      messages: [],
    }
  end

  def create_board() do
    row = [nil, nil, nil, nil, nil, nil, nil]
    for _ <- 0..5, do: row
  end

  def move(game, role, column_index) do
    row_index_from_end = Enum.reverse(game.board)
    |> Enum.find_index(fn (row) -> !Enum.at(row, column_index) end)
    row_index = Enum.count(game.board) - 1 - row_index_from_end
    new_board = List.update_at(game.board, row_index, fn (row) -> List.replace_at(row, column_index, role) end)
    winner =
      if is_game_over?(new_board, role, column_index, row_index) do
        role
      else
       nil
    end
    %{game | board: new_board, turn: (if role == :yellow, do: :red, else: :yellow), winner: winner}
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

  def row_win?(board, role, row_index) do
    Enum.at(board, row_index) |> is_four_in_row?(role)
  end

  def column_win?(board, role, column_index) do
    # http://langintro.com/elixir/article2/
    flipped = for i <- 0..5 do
      Enum.map(board, fn(column) ->
        if i <= 5, do: Enum.at(column, i)
      end)
    end
    Enum.at(flipped, column_index) |> is_four_in_row?(role)
  end

  def diagonal_win?(board, role) do
    flat_board = List.flatten(board)
    IO.inspect flat_board
    left_diagonal = Enum.take_every(flat_board, 8)
    # left_diagonal_back = Enum.take_every(Enum.reverse(flat_board), 7)
    # right_diagonal_back = Enum.take_every(Enum.reverse(flat_board), 9)
    right_diagonal = Enum.take_every(flat_board, 10)
    diagonals = left_diagonal ++ right_diagonal
    IO.inspect left_diagonal
    IO.inspect right_diagonal

    false
  end

  def is_game_over?(board, role, column_index, row_index) do
    true
    cond do
      column_win?(board, role, column_index) ->
        true
      row_win?(board, role, row_index) ->
        true
      diagonal_win?(board, role) ->
        true
      true ->
        false
    end
  end
end


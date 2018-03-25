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
    %{game | board: new_board, turn: (if role == :yellow, do: :red, else: :yellow)}
  end
end

defmodule Game.Puzzle do
  alias Game.Puzzle.MultPuzzle

  # -> {puzzle, seed}
  def next(seed) do
    MultPuzzle.next(seed)
  end

  def correct?(%{result: result}, player_guess) do
    player_guess == result
  end

  def to_string(puzzle) do
    MultPuzzle.to_string(puzzle)
  end
end

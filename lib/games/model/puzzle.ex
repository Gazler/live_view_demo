defmodule LiveViewDemo.Games.Model.Puzzle do
  alias LiveViewDemo.Games.Model.MultPuzzle

  @opaque t :: MultPuzzle.t()

  @spec new(:rand.state()) :: {:ok, t()} | {:error, any()}
  def new(seed_state) do
    case MultPuzzle.new(seed_state) do
      {:ok, mult_puzzle} -> {:ok, mult_puzzle}
    end
  end

  @spec next(t()) :: t()
  def next(puzzle) do
    MultPuzzle.next(puzzle)
  end

  @spec correct?(t(), integer()) :: boolean()
  def correct?(puzzle, guess) do
    MultPuzzle.correct?(puzzle, guess)
  end

  @spec to_string(t()) :: String.t()
  def to_string(puzzle) do
    MultPuzzle.to_string(puzzle)
  end
end

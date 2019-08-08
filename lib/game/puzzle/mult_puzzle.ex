defmodule Game.Puzzle.MultPuzzle do
  defstruct [:factor1, :factor2, :result]
  alias Game.Puzzle.MultPuzzle

  def next(seed) do
    {f1, seed} = :rand.uniform_s(10, seed)
    {f2, seed} = :rand.uniform_s(10, seed)
    {%MultPuzzle{factor1: f1, factor2: f2, result: f1 * f2}, seed}
  end

  def to_string(%MultPuzzle{factor1: f1, factor2: f2}) do
    "#{f1} x #{f2} ="
  end
end

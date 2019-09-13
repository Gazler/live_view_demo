defmodule LiveViewDemo.Games.Model.Game do
  defstruct [:remaining_time, :puzzle, :seed_state]

  alias LiveViewDemo.Games.Model.{Game, Puzzle}

  @opaque t :: %__MODULE__{
            remaining_time: integer(),
            puzzle: Puzzle.t()
          }

  @spec new(:rand.seed_state()) :: {:ok, t()} | {:error, any()}
  def new(seed_state) do
    case Puzzle.new(seed_state) do
      {:ok, puzzle} ->
        {:ok,
         %Game{
           puzzle: puzzle,
           remaining_time: 10
         }}

      {:error, _} = error ->
        error
    end
  end

  @spec guess(t(), integer()) :: {:correct, t()} | {:incorrect, t()}
  def guess(game, guess) do
    case Puzzle.correct?(game.puzzle, guess) do
      true ->
        {:ok, next_puzzle} = Puzzle.next(game.puzzle)

        {:correct,
         %{
           game
           | remaining_time: game.remaining_time + 1,
             puzzle: next_puzzle
         }}

      false ->
        {:incorrect, game}
    end
  end

  @spec to_map(t()) :: map()
  def to_map(game) do
    game
    |> Map.from_struct()
    |> Map.update!(:puzzle, &Puzzle.to_string/1)
    |> Map.take([:remaining_time, :puzzle])
  end
end

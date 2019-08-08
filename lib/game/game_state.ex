defmodule Game.GameState do
  defstruct [:remaining_time, :puzzle, :seed]

  alias Game.{GameState, Puzzle}

  def new(seed) do
    {puzzle, seed} = Puzzle.next(seed)

    %GameState{
      puzzle: puzzle,
      remaining_time: 10,
      seed: seed
    }
  end

  def dec_time(%GameState{remaining_time: time} = game_state) do
    %{game_state | remaining_time: time - 1}
  end

  def inc_time(%GameState{remaining_time: time} = game_state) do
    %{game_state | remaining_time: time + 1}
  end

  def next_puzzle(%GameState{seed: seed} = game_state) do
    {puzzle, seed} = Puzzle.next(seed)
    %GameState{game_state | puzzle: puzzle, seed: seed}
  end
end

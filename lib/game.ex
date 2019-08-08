defmodule Game do
  alias Game.{GameServer, GameState, Puzzle}

  @doc """
  An example seed: :rand.seed_s(:exsss)
  """
  def new(seed) do
    GameState.new(seed)
  end

  def player_input(game_state, player_input) do
    if Puzzle.correct?(game_state.puzzle, player_input) do
      game_state =
        game_state
        |> GameState.inc_time()
        |> GameState.next_puzzle()

      {:correct, game_state}
    else
      {:incorrect, game_state}
    end
  end

  def tick(game_state) do
    game_state
    |> GameState.dec_time()
  end

  def public_state(game_state) do
    {game_state.remaining_time, Puzzle.to_string(game_state.puzzle)}
  end
end

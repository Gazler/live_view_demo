defmodule LiveViewDemo.Games.Service.Games do
  alias LiveViewDemo.Games.{DA, Model}

  @type update_fn :: (map() -> :ok)

  @spec new(update_fn()) :: {:ok, pid()}
  def new(update_fn) do
    seed_state = :rand.seed_s(:exsss)
    DA.Games.start_link(seed_state, update_fn)
  end

  @spec player_input(pid(), String.t() | integer()) :: map()
  def player_input(pid, string_or_integer) do
    {guess, game} = DA.Games.player_input(pid, string_or_integer)

    game
    |> Model.Game.to_map()
    |> Map.put(:guess, Model.Guess.to_integer(guess))
  end

  @spec clear(pid()) :: map()
  def clear(pid) do
    seed_state = :rand.seed_s(:exsss)

    pid
    |> DA.Games.clear(seed_state)
    |> Model.Game.to_map()
    |> Map.put(:guess, "")
  end
end

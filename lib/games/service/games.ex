defmodule LiveViewDemo.Games.Service.Games do
  alias LiveViewDemo.Games.{DA, Model}

  @spec new() :: {:ok, pid()}
  def new() do
    seed_state = :rand.seed_s(:exsss)
    DA.Games.start_link(seed_state)
  end

  @spec player_input(pid(), String.t() | integer()) :: {:correct, map()} | {:incorrect, map()}
  def player_input(pid, string_or_integer) do
    with {:ok, guess} = Model.Guess.new(string_or_integer),
         {correct_or_incorrect, game} = DA.Games.player_input(pid, guess) do
      {correct_or_incorrect, Model.Game.to_map(game)}
    end
  end

  @spec tick(pid()) :: {:continue, map()} | {:stop, map()}
  def tick(pid) do
    with {stop_or_continue, game} = DA.Games.tick(pid) do
      {stop_or_continue, Model.Game.to_map(game)}
    end
  end

  @spec running?(pid()) :: boolean()
  def running?(pid), do: Process.alive?(pid)
end

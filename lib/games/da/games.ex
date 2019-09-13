defmodule LiveViewDemo.Games.DA.Games do
  use GenServer
  alias LiveViewDemo.Games.Model.{Game, Guess}

  def start_link(seed_state) do
    GenServer.start_link(__MODULE__, seed_state)
  end

  @spec tick(pid()) :: {:continue, Game.t()} | {:stop, Game.t()}
  def tick(pid) do
    GenServer.call(pid, :tick)
  end

  @spec player_input(pid(), Guess.t()) :: {:correct, Game.t()} | {:incorrect, Game.t()}
  def player_input(pid, input) do
    GenServer.call(pid, {:player_input, input})
  end

  @impl true
  def init(seed) do
    Game.new(seed)
  end

  @impl true
  def handle_call(:tick, _from, game) do
    case Game.tick(game) do
      {:continue, game} = reply ->
        {:reply, reply, game}

      {:stop, game} = reply ->
        {:stop, :normal, reply, game}
    end
  end

  def handle_call({:player_input, input}, _from, game) do
    {correct_or_incorrect, game} = Game.guess(game, input)
    {:reply, {correct_or_incorrect, game}, game}
  end
end

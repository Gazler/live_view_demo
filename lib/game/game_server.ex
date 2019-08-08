defmodule Game.GameServer do
  use GenServer
  alias Game

  def start_link(seed) do
    GenServer.start_link(__MODULE__, seed)
  end

  def tick(pid) do
    GenServer.call(pid, :tick)
  end

  def player_input(pid, input) do
    GenServer.call(pid, {:player_input, input})
  end

  @impl true
  def init(seed) do
    {:ok, Game.new(seed)}
  end

  @impl true
  def handle_call(:tick, _from, game) do
    game = Game.tick(game)
    {:reply, Game.public_state(game), game}
  end

  def handle_call({:player_input, input}, _from, game) do
    {correct_or_incorrect, game} = Game.player_input(game, input)
    {:reply, {correct_or_incorrect, Game.public_state(game)}, game}
  end
end

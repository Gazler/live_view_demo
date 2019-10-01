defmodule LiveViewDemo.Games.DA.Games do
  use GenServer
  alias LiveViewDemo.Games.Model.{Game, GameFSM, Guess}

  @typep state :: %{
           fsm: GameFSM.t(),
           game: Game.t()
         }

  def start_link(seed_state, update_fn) do
    GenServer.start_link(__MODULE__, %{seed_state: seed_state, update_fn: update_fn})
  end

  @spec player_input(pid(), String.t()) :: {Guess.t(), Game.t()}
  def player_input(pid, input) do
    GenServer.call(pid, {:player_input, input})
  end

  @spec clear(pid(), :rand.state()) :: Game.t()
  def clear(pid, seed_state) do
    GenServer.call(pid, {:clear, seed_state})
  end

  @impl true
  def init(%{seed_state: seed_state, update_fn: update_fn}) do
    {:ok, game} = Game.new(seed_state)
    fsm = GameFSM.new()
    :timer.send_interval(1000, :tick)
    {:ok, %{game: game, fsm: fsm, update_fn: update_fn}}
  end

  @impl true
  def handle_info(:tick, state) do
    with {:ok, rules} <- GameFSM.check(state.fsm, :tick),
         {continue_or_stop, game} <- Game.tick(state.game),
         {:ok, fsm} <- GameFSM.check(rules, {:continue?, continue_or_stop}) do
      state.update_fn.(Game.to_map(game))

      state
      |> update_fsm(fsm)
      |> update_game(game)
      |> noreply()
    else
      :error -> noreply(state)
    end
  end

  @impl true
  def handle_call({:player_input, input}, _from, state) do
    with {:ok, fsm} <- GameFSM.check(state.fsm, {:digit, input}),
         {:ok, guess} <- Guess.new(GameFSM.current_guess(fsm)),
         {correct_or_incorrect, game} = Game.guess(state.game, guess),
         {:ok, fsm} <- GameFSM.check(fsm, {:correct?, correct_or_incorrect}) do
      state
      |> update_fsm(fsm)
      |> update_game(game)
      |> reply({GameFSM.current_guess(fsm), game})
    else
      :error -> reply(state, {GameFSM.current_guess(state.fsm), state.game})
      {:error, _reason} -> reply(state, {"", state.game})
    end
  end

  def handle_call({:clear, seed_state}, _from, state) do
    with {:ok, fsm} <- GameFSM.check(state.fsm, :clear) do
      game =
        if not GameFSM.running?(state.fsm) do
          {:ok, game} = Game.new(seed_state)
          game
        else
          state.game
        end

      state
      |> update_fsm(fsm)
      |> update_game(game)
      |> reply(game)
    else
      :error -> reply("", state)
    end
  end

  @spec update_game(state(), Game.t()) :: state()
  defp update_game(state, game) do
    %{state | game: game}
  end

  @spec update_game(state(), GameFSM.t()) :: state()
  defp update_fsm(state, fsm) do
    %{state | fsm: fsm}
  end

  defp reply(state, reply) do
    {:reply, reply, state}
  end

  defp noreply(state) do
    {:noreply, state}
  end
end

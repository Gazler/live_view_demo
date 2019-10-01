defmodule LiveViewDemo.Games.Model.GameFSM do
  defstruct state: :running, current_guess: ""

  @typep state :: :stopped | :running
  @type action ::
          :clear
          | :tick
          | {:digit, String.t()}
          | {:continue?, :continue | :stop}
          | {:correct?, :correct | :incorrect}
  @type guess :: String.t()

  @opaque t :: %__MODULE__{
            state: state(),
            current_guess: guess()
          }

  @spec new() :: t()
  def new() do
    %__MODULE__{}
  end

  @spec check(t(), action()) :: {:ok, t()} | :error
  def check(%__MODULE__{state: :stopped}, :clear) do
    {:ok, %__MODULE__{state: :running, current_guess: ""}}
  end

  def check(%__MODULE__{state: :running} = state, :clear) do
    {:ok, %__MODULE__{state | current_guess: ""}}
  end

  def check(%__MODULE__{state: :running} = state, {:digit, digit}) do
    {:ok, %__MODULE__{state | current_guess: state.current_guess <> digit}}
  end

  def check(%__MODULE__{state: :running} = state, {:continue?, :continue}) do
    {:ok, state}
  end

  def check(%__MODULE__{state: :running} = state, {:continue?, :stop}) do
    {:ok, %__MODULE__{state | state: :stopped}}
  end

  def check(%__MODULE__{state: :running} = state, :tick) do
    {:ok, state}
  end

  def check(%__MODULE__{state: :running} = state, {:correct?, :correct}) do
    {:ok, %__MODULE__{state | current_guess: ""}}
  end

  def check(%__MODULE__{state: :running} = state, {:correct?, :incorrect}) do
    {:ok, state}
  end

  def check(_state, _action), do: :error

  @spec current_guess(t()) :: guess()
  def current_guess(%__MODULE__{current_guess: guess}) do
    guess
  end

  @spec running?(t()) :: boolean()
  def running?(%__MODULE__{state: state}) do
    case state do
      :running -> true
      :stopped -> false
    end
  end
end

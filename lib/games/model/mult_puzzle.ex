defmodule LiveViewDemo.Games.Model.MultPuzzle do
  defstruct [:factor1, :factor2, :result, :seed_state]

  alias LiveViewDemo.Games.Model.MultPuzzle

  @opaque t :: %__MODULE__{
            factor1: integer(),
            factor2: integer(),
            result: integer(),
            seed_state: :rand.seed_state()
          }

  @spec new(:rand.seed_state()) :: {:ok, t()} | {:error, any()}
  def new(seed_state) do
    case cast(seed_state) do
      {:ok, seed_state} ->
        next_puzzle(seed_state)

      {:error, _} = error ->
        error
    end
  end

  defp cast({_alg_type, _alg_state} = seed_state) do
    {:ok, seed_state}
  end

  defp cast(_), do: {:error, "Please use :rand.seed_s(:exsss)"}

  @spec next(t()) :: t()
  def next(%MultPuzzle{seed_state: seed_state}) do
    next_puzzle(seed_state)
  end

  defp next_puzzle(seed_state) do
    {f1, seed_state} = :rand.uniform_s(10, seed_state)
    {f2, seed_state} = :rand.uniform_s(10, seed_state)
    %MultPuzzle{factor1: f1, factor2: f2, result: f1 * f2, seed_state: seed_state}
  end

  @spec correct?(t(), integer()) :: boolean()
  def correct?(%MultPuzzle{result: result}, guess) do
    guess == result
  end

  @spec to_string(t()) :: String.t()
  def to_string(%MultPuzzle{factor1: f1, factor2: f2}) do
    "#{f1} x #{f2} ="
  end
end

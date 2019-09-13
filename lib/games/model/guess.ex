defmodule LiveViewDemo.Games.Model.Guess do
  @opaque t() :: integer()

  @spec new(String.t() | integer()) :: {:ok, t()} | {:error, any()}
  def new(integer_or_string) do
    cast(integer_or_string)
  end

  defp cast(integer) when is_integer(integer), do: {:ok, integer}
  defp cast(string) when is_binary(string), do: {:ok, String.to_integer(string)}
  defp cast(_), do: {:error, "Please provide an integer"}

  @spec to_integer(t()) :: integer()
  def to_integer(guess), do: guess
end

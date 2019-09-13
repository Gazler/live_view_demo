defmodule LiveViewDemo.Games do
  use Boundary, deps: [], exports: []
  alias LiveViewDemo.Games.Service

  @spec new() :: {:ok, pid()}
  defdelegate new(), to: Service.Games

  @spec player_input(pid(), String.t() | integer()) :: {:correct, map()} | {:incorrect, map()}
  defdelegate player_input(pid, string_or_integer), to: Service.Games

  @spec tick(pid()) :: {:continue, map()} | {:stop, map()}
  defdelegate tick(pid), to: Service.Games
end

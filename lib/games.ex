defmodule LiveViewDemo.Games do
  use Boundary, deps: [], exports: []
  alias LiveViewDemo.Games.Service

  @spec new(Service.Games.update_fn()) :: {:ok, pid()}
  defdelegate new(update_fn), to: Service.Games

  @spec player_input(pid(), String.t() | integer()) :: map()
  defdelegate player_input(pid, string_or_integer), to: Service.Games

  @spec clear(pid()) :: map()
  defdelegate clear(pid), to: Service.Games
end

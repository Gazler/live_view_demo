defmodule LiveViewDemoWeb.GameLive do
  use Phoenix.LiveView
  alias LiveViewDemo.Games

  defmodule PlayerInput do
    defstruct [:guessed_number]
  end

  def render(assigns) do
    ~L"""
    <div>
      <div style="background-color: blue; width: <%= @remaining_time %>%; height: 2em; margin-left: auto; margin-right: auto;"></div>
      <div style="text-align: center; font-size: 2em; width: 100%;">Type the result of multiplication to begin</div><div style="text-align: center; font-size: 2em; width: 100%;">Your score: 0</div><div style="text-align: center; font-size: 2em; width: 100%;">
        <%= @puzzle %>
      </div>
      <div style="text-align: center; font-size: 2em; width: 100%;">
      <p>TODO PRINT GUESS</p>
      </div>
    </div>
    """
  end

  def mount(_session, socket) do
    socket =
      socket
      |> maybe_start_game()
      |> assign(%{remaining_time: 0, puzzle: ""})

    {:ok, socket}
  end

  defp maybe_start_game(socket) do
    if connected?(socket) do
      {:ok, game_handle} = Games.new()
      {:ok, timer_reference} = :timer.send_interval(1000, self(), :tick)

      socket
      |> assign(%{
        timer_reference: timer_reference,
        game_handle: game_handle
      })
    else
      socket
    end
  end

  def handle_info(:tick, socket) do
    case Games.tick(socket.assigns.game_handle) do
      {:continue, game} ->
        {:noreply, assign(socket, game)}

      {:stop, game} ->
        :timer.cancel(socket.assigns.timer_reference)
        {:noreply, assign(socket, game)}
    end
  end
end

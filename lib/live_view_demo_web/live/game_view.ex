defmodule LiveViewDemoWeb.GameLive do
  use Phoenix.LiveView
  alias LiveViewDemo.Games

  defmodule PlayerInput do
    defstruct [:guessed_number]
  end

  def render(assigns) do
    ~L"""
    <div phx-keydown="digit" phx-target="window">
      <div style="background-color: blue; width: <%= @remaining_time %>%; height: 2em; margin-left: auto; margin-right: auto;"></div>
      <div style="text-align: center; font-size: 2em; width: 100%;">
        Type the result of multiplication to begin
      </div><div style="text-align: center; font-size: 2em; width: 100%;">
        Your score: <%= @score %>
      </div>
      <div style="text-align: center; font-size: 2em; width: 100%;">
        <%= @puzzle %>
      </div>
      <div style="text-align: center; font-size: 2em; width: 100%;">
        <p> <%= @guess %></p>
      </div>
    </div>
    """
  end

  def mount(_session, socket) do
    socket =
      socket
      |> maybe_start_game()
      |> assign(%{remaining_time: 0, puzzle: "", guess: "", score: 0})

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

  def handle_event("digit", key, socket) do
    potential_number = key["key"]

    case Integer.parse(potential_number) do
      :error ->
        {:noreply, socket}

      {_integer, ""} ->
        new_guess = socket.assigns.guess <> potential_number

        case Games.player_input(socket.assigns.game_handle, new_guess) do
          {:correct, game_state} ->
            socket =
              socket
              |> assign(%{guess: ""})
              |> assign(game_state)

            {:noreply, socket}

          {:incorrect, game_state} ->
            socket =
              socket
              |> assign(%{guess: new_guess})
              |> assign(game_state)

            {:noreply, socket}
        end
    end
  end
end

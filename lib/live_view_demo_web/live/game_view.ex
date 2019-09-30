defmodule LiveViewDemoWeb.GameLive do
  use Phoenix.LiveView
  alias LiveViewDemo.Games

  defmodule PlayerInput do
    defstruct [:guessed_number]
  end

  def render(assigns) do
    ~L"""
    <div phx-keydown="keypress" phx-target="window" class="page">
      <div class="timer" style="width: <%= @remaining_time * 27 %>px;"></div>
      <div style="text-align: center; font-size: 2em; width: 100%;">
        Score: <%= @score %>
      </div>
      <div style="text-align: center; font-size: 2em; width: 100%;">
        <%= @puzzle %>
      </div>
      <div class="guess">
        <p><%= @guess %>&nbsp;</p>
      </div>
      <div class="keypad">
        <%= keypad() %>
      </div>
    </div>
    """
  end

  defp keypad do
    {:safe, [Enum.map(1..9, &key/1), empty(), key(0), clear()]}
  end

  defp key(digit) do
    """
    <div onclick="" class="key" phx-click="keyclick" phx-value-button="#{digit}">#{digit}</div>
    """
  end

  defp empty do
    """
    <div class="key"></div>
    """
  end

  defp clear do
    """
    <div onclick="" class="key" phx-click="keyclick" phx-value-button="clear">Clear<br />(Space)</div>
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

  def handle_event("keypress", key, socket) do
    pressed_key = key["key"]
    parse_result = Integer.parse(pressed_key)

    cond do
      pressed_key == " " ->
        clear(socket)

      :error == parse_result ->
        noreply(socket)

      {_integer, ""} = parse_result ->
        digit(pressed_key, socket)
    end
  end

  def handle_event("keyclick", key_press, socket) do
    button = key_press["button"]

    case button do
      "clear" ->
        clear(socket)

      button ->
        digit(button, socket)
    end
  end

  defp digit(pressed_key, socket) do
    if Games.running?(socket.assigns.game_handle) do
      new_guess = socket.assigns.guess <> pressed_key

      case Games.player_input(socket.assigns.game_handle, new_guess) do
        {:correct, game_state} ->
          socket
          |> assign(%{guess: ""})
          |> assign(game_state)
          |> noreply()

        {:incorrect, game_state} ->
          socket
          |> assign(%{guess: new_guess})
          |> assign(game_state)
          |> noreply()
      end
    else
      noreply(socket)
    end
  end

  defp clear(socket) do
    if Games.running?(socket.assigns.game_handle) do
      socket
      |> assign(%{guess: ""})
      |> noreply()
    else
      socket
      |> maybe_start_game()
      |> noreply()
    end
  end

  defp noreply(socket), do: {:noreply, socket}
end

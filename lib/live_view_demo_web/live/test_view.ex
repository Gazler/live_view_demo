defmodule LiveViewDemoWeb.TestLive do
  use Phoenix.LiveView

  defmodule PlayerInput do
    defstruct [:guessed_number]
  end

  def render(assigns) do
    ~L"""
    <input type=text value="<% @guess %>" phx-keyup="guess" phx-value="<%= @guess %>">
    """
  end

  def mount(_session, socket) do
    socket =
      socket
      |> assign(%{guess: 7})

    {:ok, socket}
  end

  def handle_event("guess", value, socket) do
    case value do
      "7" -> {:noreply, assign(socket, %{guess: 10})}
      _ -> {:noreply, socket}
    end
  end
end

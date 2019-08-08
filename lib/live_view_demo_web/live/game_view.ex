defmodule LiveViewDemoWeb.GameLive do
  use Phoenix.LiveView
  import Phoenix.HTML.Form
  alias Game.GameServer

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
      <%= f = form_for @changeset, "#", [phx_change: "guess"] %>
        <%= text_input f, :guessed_number %>
      </form>
      </div
    </div>
    """
  end

  def mount(_session, socket) do
    {:ok, pid} = GameServer.start_link(:rand.seed(:exsss))
    if connected?(socket), do: :timer.send_interval(1000, self(), :tick)

    socket =
      socket
      |> assign(%{
        changeset: player_input_changeset(%{}),
        server_pid: pid,
        remaining_time: 0,
        puzzle: ""
      })

    {:ok, socket}
  end

  def handle_event("guess", %{"player_input" => %{"guessed_number" => ""}}, socket) do
    {:noreply, socket}
  end

  def handle_event("guess", %{"player_input" => player_input}, socket) do
    pid = socket.assigns.server_pid

    changeset =
      player_input
      |> player_input_changeset()

    {correct_or_incorrect, {remaining_time, puzzle}} =
      GameServer.player_input(pid, changeset.changes.guessed_number)

    changeset =
      case correct_or_incorrect do
        :correct ->
          # Ecto.Changeset.put_change(changeset, :guessed_number, "")
          player_input_changeset(%{})

        :incorrect ->
          changeset
      end

    {:noreply,
     assign(
       socket,
       %{changeset: changeset, remaining_time: remaining_time, puzzle: puzzle}
     )}
  end

  def handle_info(:tick, socket) do
    pid = socket.assigns.server_pid
    {remaining_time, puzzle} = GameServer.tick(pid)

    {:noreply, assign(socket, %{remaining_time: remaining_time, puzzle: puzzle})}
  end

  defp player_input_changeset(params) do
    types = %{guessed_number: :integer}

    {%PlayerInput{}, types}
    |> Ecto.Changeset.cast(params, Map.keys(types))
  end
end

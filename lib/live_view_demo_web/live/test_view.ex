defmodule LiveViewDemoWeb.TestLive do
  use Phoenix.LiveView
  import Phoenix.HTML.Form

  defmodule PlayerInput do
    defstruct [:guessed_number]
  end

  def render(assigns) do
    ~L"""
    <%= f = form_for @changeset, "#", [phx_change: "guess"] %>
    <%= text_input f, :guessed_number %>
    </form>
    """
  end

  def mount(_session, socket) do
    socket =
      socket
      |> assign(%{changeset: player_input_changeset(%{guessed_number: 9})})

    {:ok, socket}
  end

  def handle_event("guess", %{"player_input" => %{"guessed_number" => ""}}, socket) do
    {:noreply, socket}
  end

  def handle_event("guess", %{"player_input" => player_input}, socket) do
    changeset =
      player_input
      |> player_input_changeset()

    case changeset.changes.guessed_number do
      10 ->
        {:noreply,
         assign(
           socket,
           %{changeset: player_input_changeset(%{guessed_number: 100})}
         )}

      _ ->
        {:noreply,
         assign(
           socket,
           %{changeset: changeset}
         )}
    end
  end

  defp player_input_changeset(params) do
    types = %{guessed_number: :integer}

    {%PlayerInput{}, types}
    |> Ecto.Changeset.cast(params, Map.keys(types))
  end
end

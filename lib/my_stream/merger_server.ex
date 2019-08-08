defmodule MyStream.MergeServer do
  use GenServer

  # I am expecting only one caller, so in case there are no values
  # I will set reply_to to the caller pid
  # If streams generate values faster than caller consumes them,
  # the server stores them in a list
  defstruct values: [], reply_to: nil

  # Client API
  def start_link(), do: GenServer.start_link(__MODULE__, [])

  def wait_for_next_value(pid), do: GenServer.call(pid, :wait_for_next_value)

  def publish_value(pid, value), do: GenServer.cast(pid, {:publish_value, value})

  # Callbacks
  @impl true
  def init(_) do
    {:ok, %__MODULE__{}}
  end

  @impl true
  def handle_call(:wait_for_next_value, from, %__MODULE__{values: []} = state) do
    # hang the caller until we have something to return
    {:noreply, %__MODULE__{state | reply_to: from}}
  end

  def handle_call(:wait_for_next_value, _from, %__MODULE__{values: [value | rest]}) do
    {:reply, value, %__MODULE__{values: rest, reply_to: nil}}
  end

  @impl true
  def handle_cast({:publish_value, value}, %__MODULE__{values: values, reply_to: nil}) do
    # For performance, the stream will behave like stack
    # For fast coming events the order doesn't matter that much
    {:noreply, %__MODULE__{values: [value | values], reply_to: nil}}
  end

  def handle_cast({:publish_value, value}, %__MODULE__{values: values, reply_to: reply_to}) do
    GenServer.reply(reply_to, value)

    {:noreply, %__MODULE__{values: values, reply_to: nil}}
  end
end

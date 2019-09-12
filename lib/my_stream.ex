defmodule MyStream do
  use Boundary, deps: [], exports: []
  alias MyStream.MergeServer

  def test() do
    s1 = Stream.interval(1000) |> Stream.map(fn _ -> :fast end)
    s2 = Stream.interval(5000) |> Stream.map(fn _ -> :slow end)
    s3 = MyStream.merge([s1, s2])
    Stream.each(s3, &IO.inspect(&1))
  end

  def merge(list_of_streams) do
    Stream.resource(
      fn ->
        {:ok, server_pid} = MergeServer.start_link()

        list_of_streams
        |> Enum.map(fn stream ->
          Task.start_link(fn ->
            Stream.each(stream, fn value ->
              MergeServer.publish_value(server_pid, value)
            end)
            |> Stream.run()
          end)
        end)

        server_pid
      end,
      fn server_pid ->
        value = MergeServer.wait_for_next_value(server_pid)
        {[value], server_pid}
      end,
      fn server_pid -> GenServer.stop(server_pid) end
    )
  end

  def next(continuation) when is_function(continuation, 1) do
    case continuation.({:cont, :ignored_accumulator}) do
      # extract element and return continuation
      {:suspended, {:element, element}, continuation} ->
        {element, continuation}

      # halted with value
      {:halted, {:element, element}} ->
        {element, &fake_continuation/1}

      # halted without value
      {:halted, _} ->
        nil

      # done *probably* doesn't return values
      {:done, _} ->
        nil
    end
  end

  # Entry point
  def next(stream) do
    # Tag the value with :element to differentiate it later from empty values
    # in the unlikely case that someone had `:ignored_accumulator` as an element of the stream
    continuation = &Enumerable.reduce(stream, &1, fn x, _acc -> {:suspend, {:element, x}} end)
    next(continuation)
  end

  # The stream already finished but the API is nicer if MyStream.next returns nil in the next call
  defp fake_continuation(_), do: {:done, :ignored_accumulator}
end

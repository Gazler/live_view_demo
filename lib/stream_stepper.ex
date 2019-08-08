defmodule StreamStepper do
  def stream_stepper(stream) do
    stream
    |> Enumerable.reduce({:cont, nil}, &stream_stepper_suspender/2)
    |> stream_stepper_continuer()
  end

  defp stream_stepper_suspender(head, nil) do
    {:suspend, {head}}
  end

  defp stream_stepper_continuer({done_halted, nil}) when done_halted in [:done, :halted] do
    []
  end

  defp stream_stepper_continuer({done_halted, {head}}) when done_halted in [:done, :halted] do
    tail = fn -> [] end
    [head | tail]
  end

  defp stream_stepper_continuer({:suspended, {head}, tail_cont}) do
    once = callable_once()
    tail = fn -> once.(fn -> tail_cont.({:cont, nil}) |> stream_stepper_continuer() end) end
    [head | tail]
  end

  defp callable_once do
    seen = :atomics.new(1, [])

    fn fun ->
      case :atomics.compare_exchange(seen, 1, 0, 1) do
        :ok -> fun.()
        _ -> raise "protected fun evaluated twice!"
      end
    end
  end
end


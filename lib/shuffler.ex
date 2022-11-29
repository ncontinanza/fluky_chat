defmodule Shuffler do
  @enforce_keys [:shuffler_pid]
  defstruct [:shuffler_pid]

  def start do
    {:ok, pid} = Agent.start_link(fn -> %{} end)
    %Shuffler{shuffler_pid: pid}
  end

  def shuffle(
        %Shuffler{shuffler_pid: shuffler_pid} = shuffler,
        active_clients
      ) do
    cond do
      ActiveClients.empty?(active_clients) ->
        active_clients

      true ->
        Agent.update(shuffler_pid, fn _ -> %{} end)

        ActiveClients.get_all_clients(active_clients)
        |> Map.keys()
        |> MapSet.new()
        |> do_shuffle(shuffler)
    end
  end

  defp do_shuffle(pid_set, %Shuffler{shuffler_pid: shuffler_pid} = shuffler) do
    IO.inspect(pid_set, label: "PID SET: ")

    if Enum.empty?(pid_set) do
      :ok
    else
      [pid_x, pid_y] = Enum.take_random(pid_set, 2)
      Shuffler.update(shuffler, pid_x, pid_y)

      pid_set
      |> MapSet.delete(pid_x)
      |> MapSet.delete(pid_y)
      |> do_shuffle(shuffler_pid)
    end
  end

  def update(%Shuffler{shuffler_pid: shuffler_pid}, pid_x, pid_y) do
    Agent.update(shuffler_pid, &Map.put(&1, pid_x, pid_y))
    Agent.update(shuffler_pid, &Map.put(&1, pid_y, pid_x))
  end
end

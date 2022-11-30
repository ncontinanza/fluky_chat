defmodule Shuffler do
  @enforce_keys [:shuffler_pid]
  defstruct [:shuffler_pid]

  def start do
    {:ok, pid} = Agent.start_link(fn -> %{} end)
    %Shuffler{shuffler_pid: pid}
  end

  def shuffle(%Shuffler{shuffler_pid: shuffler_pid} = shuffler, active_clients) do
    cond do
      ActiveClients.empty?(active_clients) ->
        active_clients

      true ->
        Agent.update(shuffler_pid, fn _state -> %{} end)

        ActiveClients.get_all_clients(active_clients)
        |> Enum.map(&Map.get(&1, :pid))
        |> MapSet.new()
        |> do_shuffle(shuffler)
    end
  end

  defp do_shuffle(pid_set, %Shuffler{} = shuffler) do
    if Enum.empty?(pid_set) do
      :ok
    else
      [pid_x, pid_y] = Enum.take_random(pid_set, 2)
      Shuffler.update(shuffler, pid_x, pid_y)

      pid_set
      |> MapSet.delete(pid_x)
      |> MapSet.delete(pid_y)
      |> do_shuffle(shuffler)
    end
  end

  def update(%Shuffler{shuffler_pid: shuffler_pid}, pid_x, pid_y) do
    Agent.update(shuffler_pid, &Map.put(&1, pid_x, pid_y))
    Agent.update(shuffler_pid, &Map.put(&1, pid_y, pid_x))
  end

  def get_client_pair(%Shuffler{shuffler_pid: shuffler_pid}, client_pid) do
    Agent.get(shuffler_pid, fn clients_map -> Map.get(clients_map, client_pid) end)
  end

  def remove_client(%Shuffler{} = shuffler, client_pid) do
    pair_pid = Shuffler.get_client_pair(shuffler, client_pid)

    Agent.update(shuffler[:shuffler_pid], &Map.delete(&1, client_pid))
    Agent.update(shuffler[:shuffler_pid], &Map.delete(&1, pair_pid))
  end

end

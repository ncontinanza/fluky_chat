defmodule Shuffler do
  @enforce_keys [:shuffler_pid]
  defstruct [:shuffler_pid]

  def start do
    {:ok, pid} = Agent.start_link(fn -> %{} end)
    %Shuffler{shuffler_pid: pid}
  end

  def shuffle(%Shuffler{shuffler_pid: shuffler_pid} = shuffler, active_clients) do
    cond do
      Enum.empty?(active_clients) ->
        active_clients

      true ->
        old_list = Agent.get_and_update(shuffler_pid, fn old_list -> {old_list, %{}} end)

        active_clients
        |> Enum.map(&Map.get(&1, :pid))
        |> MapSet.new()
        |> do_shuffle(shuffler, old_list)
    end
  end

  defp do_shuffle(pid_set, %Shuffler{} = shuffler, old_list) do

    case Enum.count(pid_set) do
      0 -> {:ok, nil}
      1 -> {:one_left, pid_set |> Enum.at(0)}
      _ ->
        [pid_x, pid_y] = Enum.take_random(pid_set, 2)
        Shuffler.update(shuffler, pid_x, pid_y)

        pid_set
        |> MapSet.delete(pid_x)
        |> MapSet.delete(pid_y)
        |> do_shuffle(shuffler, old_list)
    end

  end

  def update(%Shuffler{shuffler_pid: shuffler_pid}, pid_x, pid_y) do
    Agent.update(shuffler_pid, &Map.put(&1, pid_x, pid_y))
    Agent.update(shuffler_pid, &Map.put(&1, pid_y, pid_x))
  end

  def get_client_pair(%Shuffler{shuffler_pid: shuffler_pid}, client_pid) do
    Agent.get(shuffler_pid, fn clients_map -> Map.get(clients_map, client_pid) end)
  end

  def remove_client(%Shuffler{shuffler_pid: shuffler_pid} = shuffler, client_pid) do
    pair_pid = Shuffler.get_client_pair(shuffler, client_pid)

    Agent.update(shuffler_pid, &Map.delete(&1, client_pid))
    Agent.update(shuffler_pid, &Map.delete(&1, pair_pid))
  end

  def get_all_pairs(%Shuffler{shuffler_pid: shuffler_pid}) do
    Agent.get(shuffler_pid, & &1)
  end

end

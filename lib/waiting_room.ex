defmodule WaitingRoom do
  @enforce_keys [:waiting_room_pid]
  defstruct [:waiting_room_pid]

  def start() do
    {:ok, pid} = Agent.start_link(fn -> [] end)
    %WaitingRoom{waiting_room_pid: pid}
  end

  def queue(%WaitingRoom{waiting_room_pid: waiting_room_pid}, %ClientConnection{} = client) do
    Agent.update(waiting_room_pid, &List.insert_at(&1, -1, client))
  end

  defp dequeue(%WaitingRoom{waiting_room_pid: waiting_room_pid}) do
    Agent.get_and_update(waiting_room_pid, &List.pop_at(&1, 0))
  end

  def try_dequeue_pair(%WaitingRoom{} = waiting_list) do

    waiting_list
    |> Map.get(:waiting_room_pid)
    |> Agent.get(&Enum.count(&1))
    |> Kernel.then(&(&1 >= 2))
    |> Kernel.if(
      do: {:ok, {dequeue(waiting_list), dequeue(waiting_list)}},
      else: {:not_enough_clients}
    )

  end

  def get_all_clients(%WaitingRoom{waiting_room_pid: waiting_room_pid}) do
    Agent.get(waiting_room_pid, & &1)
  end

end

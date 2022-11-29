defmodule WaitingRoom do
  @enforce_keys [:waiting_room_pid]
  defstruct [:waiting_room_pid]

  def start() do
    {:ok, pid} = Agent.start_link(fn -> [] end)
    %WaitingRoom{waiting_room_pid: pid}
  end

  def queue(%WaitingRoom{waiting_room_pid: waiting_room_pid}, client_pid) do
    Agent.update(waiting_room_pid, &List.insert_at(&1, -1, client_pid))
  end

  defp dequeue(%WaitingRoom{waiting_room_pid: waiting_room_pid}) do
    Agent.get_and_update(waiting_room_pid, &List.pop_at(&1, 0))
  end

  def dequeue_pair(%WaitingRoom{} = waiting_list) do
    {WaitingRoom.dequeue(waiting_list), WaitingRoom.dequeue(waiting_list)}
  end
end

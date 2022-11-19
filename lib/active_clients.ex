defmodule ActiveClients do

  @enforce_keys [:acl_pid]
  defstruct [:acl_pid]

  def start do
    {:ok, pid} = Agent.start_link(fn -> %{} end)
     %ActiveClients{ acl_pid: pid }
  end

  def add_client(%ActiveClients{acl_pid: acl_pid}, client_pid, socket) do
    Agent.update(acl_pid, &Map.put(&1, client_pid, socket))
    #Agent.update(acl.acl_pid, fn map -> Map.put(map, pid, socket) end)
  end

  def remove_client(%ActiveClients{acl_pid: acl_pid}, client_pid) do
    Agent.update(acl_pid, &Map.delete(&1, client_pid))
  end

  def get_all_clients(%ActiveClients{acl_pid: acl_pid}) do
    Agent.get(acl_pid, &(&1))
  end

end

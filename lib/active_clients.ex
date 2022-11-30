defmodule ActiveClients do
  @enforce_keys [:acl_pid]
  defstruct [:acl_pid]

  def start do
    # agents are processes for mantaining data (useful for "mutability")
    # the agent (process) will control data and its changes

    {:ok, pid} = Agent.start_link(fn -> %{} end)
    %ActiveClients{acl_pid: pid}
  end

  def add_client(%ActiveClients{acl_pid: acl_pid}, client_pid, socket) do
    Agent.update(acl_pid, &Map.put(&1, client_pid, socket))
  end

  def remove_client(%ActiveClients{acl_pid: acl_pid}, client_pid) do
    Agent.update(acl_pid, &Map.delete(&1, client_pid))
  end

  def get_all_clients(%ActiveClients{acl_pid: acl_pid}) do
    Agent.get(acl_pid, & &1)
  end

  def empty?(acl) do
    Enum.empty?(ActiveClients.get_all_clients(acl))
  end
end

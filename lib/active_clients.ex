defmodule ActiveClients do
  @enforce_keys [:acl_pid]
  defstruct [:acl_pid]

  def start do
    # agents are processes for mantaining data (useful for "mutability")
    # the agent (process) will control data and its changes

    {:ok, pid} = Agent.start_link(fn -> %{} end)
    %ActiveClients{acl_pid: pid}
  end

  def add_client(%ActiveClients{acl_pid: acl_pid}, %ClientConnection{pid: client_pid} = client) do

    Agent.update(acl_pid, &Map.put(&1, client_pid, client))
  end

  def remove_client(%ActiveClients{acl_pid: acl_pid}, client_pid) do
    Agent.get_and_update(acl_pid, &Map.pop(&1, client_pid))
  end

  def update_client(%ActiveClients{acl_pid: acl_pid}, %ClientConnection{pid: pid} = client, :nickname, value) do
    client_map = Agent.get(acl_pid, & &1)

    if Map.has_key?(client_map, pid) do
      {:ok, Agent.get_and_update(acl_pid, &update_client_nickname(&1, client, value))}
    else
      {:error, :not_found_pid}
    end

  end

  def get_client(%ActiveClients{acl_pid: acl_pid}, client_pid) do
    Agent.get(acl_pid, &Map.get(&1, client_pid))
  end

  def get_all_clients(%ActiveClients{acl_pid: acl_pid}) do
    Agent.get(acl_pid, &Map.values(&1))
  end

  def empty?(acl) do
    Enum.empty?(ActiveClients.get_all_clients(acl))
  end

  def length(acl) do
    Enum.count(ActiveClients.get_all_clients(acl))
  end

    defp update_client_nickname(client_map, %ClientConnection{pid: client_pid}, new_nick) do
    Map.update!(client_map, client_pid, &ClientConnection.update_nickname(&1, new_nick))
    |> Kernel.then(& {Map.get(&1, client_pid), &1})
  end
end

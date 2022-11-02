defmodule KVServer do
  require Logger

  def accept(port) do
    # The options below mean:
    #
    # 1. `:binary` - receives data as binaries (instead of lists)
    # 2. `packet: :line` - receives data line by line
    # 3. `active: false` - blocks on `:gen_tcp.recv/2` until data is available
    # 4. `reuseaddr: true` - allows us to reuse the address if the listener crashes
    #
    {:ok, socket} =
      :gen_tcp.listen(port, [:binary, packet: :line, active: false, reuseaddr: true])
    Logger.info("Accepting connections on port #{port}")
    {:ok, pid} = Agent.start_link(fn -> %{} end)
    loop_acceptor(socket, pid)
  end

  defp loop_acceptor(socket, client_socket_list_pid) do
    {:ok, client_socket} = :gen_tcp.accept(socket)
    {:ok, client_pid} = Task.Supervisor.start_child(KVServer.TaskSupervisor, fn -> serve(client_socket, client_socket_list_pid) end)
    :ok = :gen_tcp.controlling_process(client_socket, client_pid)
    Agent.update(client_socket_list_pid, fn map -> Map.put(map, client_pid, client_socket) end)
    loop_acceptor(socket, client_socket_list_pid)
  end

'''
  defp serve(socket, client_socket_list_pid) do
    socket
    |> read_line()
    |> write_line(client_socket_list_pid)

    serve(socket, client_socket_list_pid)
  end

  defp read_line(socket) do
    {:ok, data} = :gen_tcp.recv(socket, 0)
    data
  end

'''

'''
pid1 -> socket1
pid2 -> socket2
pid3 -> socket3
pid4 -> socket4
'''

'''
pid1 -> socket3
pid2 -> socket4
pid3 -> socket1
pid4 -> socket2
'''

defp serve(socket, client_socket_list_pid) do

  case :gen_tcp.recv(socket, 0) do
    {:ok, data} ->
      write_line(data, client_socket_list_pid)
      serve(socket, client_socket_list_pid)
    {:error, :closed} ->
      my_pid = self()
      Agent.update(client_socket_list_pid, &Map.delete(&1, my_pid))
    {:error, :enotconn} ->
      :ok
  end

end

  defp write_line(line, client_socket_list_pid) do
    for {pid, socket} <- Agent.get(client_socket_list_pid, fn map -> map end) do
      if pid != self() do
        :gen_tcp.send(socket, String.upcase(line))
      end
    end
  end
end

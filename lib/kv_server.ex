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
    acl = ActiveClientsList.start()
    loop_acceptor(socket, acl)
  end

  defp loop_acceptor(socket, acl) do
    {:ok, client_socket} = :gen_tcp.accept(socket)
    {:ok, client_pid} = Task.Supervisor.start_child(KVServer.TaskSupervisor, fn -> serve(client_socket, acl) end)
    :ok = :gen_tcp.controlling_process(client_socket, client_pid)
    acl |> ActiveClientsList.add_client(client_pid, client_socket)
    loop_acceptor(socket, acl)
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

defp serve(socket, acl) do

  case :gen_tcp.recv(socket, 0) do
    {:ok, data} ->
      write_line(data, acl)
      serve(socket, acl)
    {:error, :closed} ->
      my_pid = self()
      ActiveClientsList.remove_client(acl, my_pid)
    {:error, :enotconn} ->
      :ok
  end

end

  defp write_line(line, acl) do
    for {pid, socket} <- ActiveClientsList.get_all_clients(acl) do
      if pid != self() do
        :gen_tcp.send(socket, String.upcase(line))
      end
    end
  end
end

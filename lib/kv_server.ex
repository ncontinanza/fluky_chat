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
    acl = ActiveClients.start()
    loop_acceptor(socket, acl)
  end

  defp loop_acceptor(socket, acl) do
    {:ok, client_socket} = :gen_tcp.accept(socket)

    # create supervised process and give client the socket to be able to interact
    # use serve function for se
    {:ok, client_pid} =
      Task.Supervisor.start_child(KVServer.TaskSupervisor, fn -> serve(client_socket, acl) end)

    :ok = :gen_tcp.controlling_process(client_socket, client_pid)
    acl |> ActiveClients.add_client(client_pid, client_socket)
    loop_acceptor(socket, acl)
  end

  defp serve(socket, acl) do
    # serve acts as a client handler
    # receives message from client and sends it to the rest of clients
    case :gen_tcp.recv(socket, 0) do
      {:ok, data} ->
        write_line(data, acl)
        serve(socket, acl)
      # if connection with client got closed, remove client
      {:error, :closed} ->
        my_pid = self()
        ActiveClients.remove_client(acl, my_pid)
      #
      {:error, :enotconn} ->
        :ok
    end
  end

  defp write_line(line, acl) do
    # obtain clients map from agent with macro and unpack pid and socket
    for {pid, socket} <- ActiveClients.get_all_clients(acl) do
      if pid != self() do
        :gen_tcp.send(socket, String.upcase(line))
      end
    end
  end
end

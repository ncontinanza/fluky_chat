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

    chat_manager = %ChatManager{
      acl: ActiveClients.start(),
      shuffler: Shuffler.start(),
      waiting_room: WaitingRoom.start()
    }

    timer = Timer.start(10, chat_manager)

    loop_acceptor(socket, chat_manager, timer)
  end

  defp loop_acceptor(socket, chat_manager, timer) do
    {:ok, client_socket} = :gen_tcp.accept(socket)

    # create supervised process and give client the socket to be able to interact
    # use serve function for se
    {:ok, client_pid} =
      Task.Supervisor.start_child(KVServer.TaskSupervisor, fn ->
        ClientConnection.serve(%ClientConnection{socket: client_socket}, chat_manager, timer)
      end)

    :ok = :gen_tcp.controlling_process(client_socket, client_pid)
    # MOVE CLIENT INTO THE WAITING ROOM
    chat_manager
    |> ChatManager.move_client_into_waiting_room(%ClientConnection{
      pid: client_pid,
      socket: client_socket
    })

    loop_acceptor(socket, chat_manager, timer)
  end
end

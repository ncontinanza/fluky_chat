defmodule ChatManager do
  @enforce_keys [:acl, :shuffler, :waiting_room]
  defstruct [:acl, :shuffler, :waiting_room]

  def disconnect_client(%ChatManager{} = chat_manager, client_pid) do
    # Remove client from ActiveClients
    chat_manager
    |> Map.get(:acl)
    |> ActiveClients.remove_client(client_pid)

    # Remove client from Shuffler
    shuffler = Map.get(chat_manager, :shuffler)
    pair_pid = Shuffler.get_client_pair(shuffler, client_pid)
    Shuffler.remove_client(shuffler, client_pid)

    # Remove pair client from active clients list
    pair_client = chat_manager
                  |> Map.get(:acl)
                  |> ActiveClients.remove_client(pair_pid)

    # Move pair client from active client list to the waiting room
    chat_manager
    |> Map.get(:waiting_room)
    |> WaitingRoom.queue(pair_client)
  end

  def move_client_into_waiting_room(%ChatManager{waiting_room: waiting_room} = chat_manager, %ClientConnection{} = client) do
    # Move client to the waiting room
    WaitingRoom.queue(waiting_room, client)

    # If could make a pair, then connect the two clients.
    case WaitingRoom.try_dequeue_pair(waiting_room) do
      {:ok, clients} -> connect_two_clients(chat_manager, clients)
      {:not_enough_clients} -> :ok
    end

  end

  defp connect_two_clients(%ChatManager{acl: acl, shuffler: shuffler}, {%ClientConnection{} = cli_x, %ClientConnection{} = cli_y}) do
    # Move clients to ActiveClients list
    ActiveClients.add_client(acl, cli_x)
    ActiveClients.add_client(acl, cli_y)

    # Connect them in the shuffler
    Shuffler.update(shuffler, Map.get(cli_x, :pid), Map.get(cli_y, :pid))

    # Return
    :ok
  end

  def try_send_message_to_pair(%ChatManager{acl: acl, shuffler: shuffler}, client_pid, message) do
    # Get pair pid
    maybe_pair_pid = Shuffler.get_client_pair(shuffler, client_pid)
    send_message(acl, maybe_pair_pid, message |> Message.with_pid(client_pid))
  end

  defp send_message(%ActiveClients{}, pid, _message) when is_nil(pid) do
    {:error, Message.client_is_not_chatting}
  end

  defp send_message(%ActiveClients{} = acl, pid, message) do
    acl
    |> ActiveClients.get_client(pid)
    |> ClientConnection.send_message(message)

    {:ok, :done}
  end

  def shuffle_clients(%ChatManager{acl: acl, shuffler: shuffler, waiting_room: waiting_room} = chat_manager) do
    # Move clients from waiting room to active clients
    waiting_room
    |> WaitingRoom.get_all_clients
    |> Enum.each(&ActiveClients.add_client(acl, &1))

    # Obtain active clients
    client_list = ActiveClients.get_all_clients(acl)

    # Shuffle
    notify_shuffling(client_list)
    Shuffler.shuffle(shuffler, client_list)
    |> if_there_is_one_left_then_move_to_waiting_list(chat_manager)

    # Say hi to everyone!
    notify_pair_nickname(chat_manager)
  end

  defp notify_shuffling(client_list) do
    IO.puts("IT'S SHUFFLE TIMEEEEEEE")
    for client_socket <- Enum.map(client_list, &Map.get(&1, :socket)) do
      :gen_tcp.send(client_socket, Message.time_to_shuffle())
    end
  end

  defp notify_pair_nickname(%ChatManager{acl: acl, shuffler: shuffler}) do
    shuffler
    |> Shuffler.get_all_pairs
    |> Enum.map(fn {pid_cli, pid_pair} -> {ActiveClients.get_client(acl, pid_cli), pid_pair} end)
    |> Enum.each(fn {client, pair_pid} ->
                      client |> ClientConnection.send_message(Message.say_hi_to(pair_pid))
                  end)
  end

  defp if_there_is_one_left_then_move_to_waiting_list({:one_left, client_pid}, %ChatManager{acl: acl, waiting_room: waiting_room}) do
    # Notify client that nobody wants to chat with him/her
    acl
    |> ActiveClients.get_client(client_pid)
    |> ClientConnection.send_message(Message.client_must_wait())

    # Move client from ActiveClients to waiting room
    client = ActiveClients.remove_client(acl, client_pid)
    WaitingRoom.queue(waiting_room, client)
  end

  defp if_there_is_one_left_then_move_to_waiting_list(_result, %ChatManager{}) do
    nil
  end
end

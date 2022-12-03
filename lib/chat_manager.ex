defmodule ChatManager do
  @enforce_keys [:acl, :shuffler, :waiting_room]
  defstruct [:acl, :shuffler, :waiting_room]

  def disconnect_client(%ChatManager{} = chat_manager, client_pid) do
    # Remove client from ActiveClients
    chat_manager
    |> Map.get(:acl)
    |> ActiveClients.remove_client(client_pid)

    # Remove client from Shuffler
    shuffler = chat_manager[:shuffler]
    pair_pid = Shuffler.get_client_pair(shuffler, client_pid)
    Shuffler.remove_client(shuffler, client_pid)

    # Remove pair client from active clients list
    chat_manager
    |> Map.get(:acl)
    |> ActiveClients.remove_client(pair_pid)

    # Move pair client from active client list to the waiting room
    pair_client = chat_manager
                  |> Map.get(:acl)
                  |> ActiveClients.remove_client(pair_pid)

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
    |> Map.get(:socket)
    |> :gen_tcp.send(message)

    {:ok, :done}
  end


end

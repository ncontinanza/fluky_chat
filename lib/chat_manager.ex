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

    # Add pair client to the waiting room
    chat_manager
    |> Map.get(:waiting_room)
    |> WaitingRoom.queue(pair_pid)
  end

  def move_to_waiting_room(%ChatManager{} = chat_manager, client_pid) do
    # Move client to the waiting room
    chat_manager
    |> Map.get(:waiting_room)
    |> WaitingRoom.queue(client_pid)

    # If could make a pair, then connect the two clients.
    case WaitingRoom.try_dequeue_pair(chat_manager[:waiting_room]) do
      {:ok, clients} -> connect_two_clients(chat_manager, clients)
      {:not_enough_clients} -> :ok
    end

  end

  defp connect_two_clients(%ChatManager{} = chat_manager, {cli_x, cli_y}) do
    # Move clients to ActiveClients list
    chat_manager
  end

end

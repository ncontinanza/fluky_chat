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

    # Move pair client to the waiting room
    chat_manager
    |> Map.get(:waiting_room)
    |> WaitingRoom.queue(pair_pid)


  end

end

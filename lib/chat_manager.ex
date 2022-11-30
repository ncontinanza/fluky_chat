defmodule ChatManager do
  @enforce_keys [:acl, :shuffler, :waiting_room]
  defstruct [:acl, :shuffler, :waiting_room]

  def disconnect_client(%ChatManager{} = chat_manager, client_pid) do
    # Remove client from ActiveClients
    chat_manager
    |> Map.get(:acl)
    |> ActiveClients.remove_client(client_pid)

    # Remove client from Shuffler
    
  end

end

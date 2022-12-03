defmodule ClientConnection do
  defstruct [:pid, :socket]

  def serve(socket, %ChatManager{} = chat_manager) do
    # serve acts as a client handler
    # receives message from client and sends it to the rest of clients
    my_pid = self()
    case :gen_tcp.recv(socket, 0) do
      {:ok, data} ->
        ChatManager.try_send_message_to_pair(chat_manager, my_pid, data)
        |> if_send_fails_then_notify_client(socket)
        serve(socket, chat_manager)
      # if connection chat_manager client got closed, remove client
      {:error, :closed} ->
        ChatManager.disconnect_client(chat_manager, my_pid)
      #
      {:error, :enotconn} ->
        :ok
    end
  end

  def if_send_fails_then_notify_client({:ok, _}, _my_socket) do
    :ok
  end

  def if_send_fails_then_notify_client({:error, reason}, my_socket) do
    :gen_tcp.send(my_socket, reason)
  end
end

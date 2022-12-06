defmodule Command do

  def execute({:m, message}, %ChatManager{} = chat_manager, client_pid, client_socket) do
    ChatManager.try_send_message_to_pair(chat_manager, client_pid, message)
    |> if_send_fails_then_notify_client(client_socket)
  end

  defp if_send_fails_then_notify_client({:ok, _}, _my_socket) do
    :ok
  end

  defp if_send_fails_then_notify_client({:error, reason}, my_socket) do
    :gen_tcp.send(my_socket, reason)
  end

end

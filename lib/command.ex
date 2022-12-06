defmodule Command do

  def execute({:m, message}, %ChatManager{} = chat_manager, %ClientConnection{pid: pid} = client, _timer) do
    ChatManager.try_send_message_to_pair(chat_manager, pid, message)
    |> if_send_fails_then_notify_client(client)
  end

  defp if_send_fails_then_notify_client({:ok, _}, %ClientConnection{} = _client) do
    :ok
  end

  defp if_send_fails_then_notify_client({:error, reason}, %ClientConnection{} = client) do
    ClientConnection.send_message(client, reason)
  end

end

defmodule Command do

  def execute({:m, message}, %ChatManager{} = chat_manager, %ClientConnection{} = client, _timer) do
    ChatManager.try_send_message_to_pair(chat_manager, client, message)
    |> if_send_fails_then_notify_client(client)

    client
  end

  def execute({:t, _}, %ChatManager{} = _chat_manager, %ClientConnection{} = client, %Timer{} = timer) do
    time_left = timer
              |> Timer.get_time
              |> Message.time_left
    ClientConnection.send_message(client, time_left)

    client
  end

  def execute({:h, _}, %ChatManager{} = _chat_manager, %ClientConnection{} = client, %Timer{} = _timer) do
    ClientConnection.send_message(client, Message.help())

    client
  end

  def execute({:n, new_nickname}, %ChatManager{} = chat_manager, %ClientConnection{} = client, %Timer{} = _timer) do
    case ChatManager.update_client(chat_manager, client, :nickname, new_nickname) do
      {:ok, updated_client} ->
        ClientConnection.send_message(client, Message.notify_nickname_update(updated_client))
        updated_client
      {:error, _} ->
        ClientConnection.send_message(client, Message.cannot_execute_command_while_not_chatting())
        client
    end
  end

  def execute({cmd, args}, %ChatManager{} = _chat_manager, %ClientConnection{} = client, %Timer{} = _timer) do
    ClientConnection.send_message(client, Message.unknown_command(cmd, args))

    client
  end

  defp if_send_fails_then_notify_client({:ok, _}, %ClientConnection{} = _client) do
    :ok
  end

  defp if_send_fails_then_notify_client({:error, reason}, %ClientConnection{} = client) do
    ClientConnection.send_message(client, reason)
  end

end

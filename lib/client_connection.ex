defmodule ClientConnection do
  defstruct [:pid, :socket, :nickname]

  def send_message(%ClientConnection{socket: socket}, message) do
    # ClientConnection will have the pid of the process who I want to send
    # the message.
    :gen_tcp.send(socket, message)
  end

  def update_nickname(%ClientConnection{pid: pid, socket: socket}, new_nick) do
    %ClientConnection{pid: pid, socket: socket, nickname: new_nick}
  end

  def serve(%ClientConnection{} = client, %ChatManager{} = chat_manager, %Timer{} = timer) do
    my_pid = self()
    client
    |> Map.put(:pid, my_pid)
    |> receive_msg(chat_manager, timer)
  end

  defp receive_msg(%ClientConnection{pid: my_pid, socket: socket} = client, %ChatManager{} = chat_manager, %Timer{} = timer) do
    case :gen_tcp.recv(socket, 0) do
      {:ok, data} ->
        data
        |> Decoder.decode_message
        |> Command.execute(chat_manager, client, timer)
        |> receive_msg(chat_manager, timer)

      # if connection chat_manager client got closed, remove client
      {:error, :closed} ->
        ChatManager.disconnect_client(chat_manager, my_pid)

      {:error, :enotconn} ->
        :ok
    end
  end
end

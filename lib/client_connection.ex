defmodule ClientConnection do
  defstruct [:pid, :socket]

  def send_message(%ClientConnection{socket: socket}, message) do
    :gen_tcp.send(socket, message)
  end

  def send_message(%ClientConnection{socket: socket}, message) do
    :gen_tcp.send(socket, message)
  end

  def serve(socket, %ChatManager{} = chat_manager, %Timer{} = timer) do
    # serve acts as a client handler
    # receives message from client and sends it to the rest of clients
    my_pid = self()
    case :gen_tcp.recv(socket, 0) do
      {:ok, data} ->
        data
        |> Decoder.decode_message
        |> Command.execute(chat_manager, %ClientConnection{pid: my_pid, socket: socket}, timer)
        serve(socket, chat_manager, timer)
      # if connection chat_manager client got closed, remove client
      {:error, :closed} ->
        ChatManager.disconnect_client(chat_manager, my_pid)
      #
      {:error, :enotconn} ->
        :ok
    end
  end
end

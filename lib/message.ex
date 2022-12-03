defmodule Message do

  def with_pid(message, client_pid) do
    "<#{inspect client_pid}>: #{message}"
  end

  def client_is_not_chatting do
    "You are not chatting with anyone!\n"
  end

end

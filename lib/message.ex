defmodule Message do

  def with_pid(message, client_pid) do
    "<#{inspect client_pid}>: #{message}"
  end

  def client_is_not_chatting do
    "You are not chatting with anyone!\n"
  end

  def time_to_shuffle do
    "It's time to shuffle!!\n"
  end

  def client_must_wait do
    "Oops! Looks like nobody is around here...\n"
  end

  def say_hi_to(client_nick) do
    "Say something nice to #{inspect client_nick}!\n"
  end

end

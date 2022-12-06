defmodule Message do

  def with_pid(message, client_pid) do
    "<#{inspect client_pid}>: #{message}"
  end

  defp info_message(msg) do
    "[INFO]: " <> msg <> "\n"
  end

  defp help_message(msg) do
    "[HELP]: " <> msg <> "\n"
  end

  def client_is_not_chatting do
    "[INFO]: You are not chatting with anyone!"
    |> info_message
  end

  def time_to_shuffle do
    "It's time to shuffle!!"
    |> info_message
  end

  def client_must_wait do
    "Oops! Looks like nobody is around here..."
    |> info_message
  end

  def say_hi_to(client_nick) do
    "Say something nice to #{inspect client_nick}!"
    |> info_message
  end

  def time_left(remaining_seconds) do
    "Time left: #{format_time(remaining_seconds)}"
    |> info_message
  end

  def help do
    help_message("COMMANDS LIST:")
    <> help_message(":h -> Displays this")
    <> help_message(":t -> Displays the remaining time until the chat shuffler")
    <> help_message(":m [message] -> Sends a message")
  end

  defp format_time(remaining_seconds) do
    {:ok, time} = Time.new(0, 0, 0, 0)

    time
    |> Time.add(remaining_seconds)
    |> Time.to_string
  end



end

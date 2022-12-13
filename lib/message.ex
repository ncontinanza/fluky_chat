defmodule Message do
  def with_pid(message, %ClientConnection{pid: pid}) do
    "<#{inspect(pid)}>: #{message}" <> "\n"
  end

  def with_nickname(message, %ClientConnection{nickname: nil} = client) do
    Message.with_pid(message, client)
  end

  def with_nickname(message, %ClientConnection{nickname: nickname} = _client) do
    "<#{nickname}>: " <> message <> "\n"
  end

  defp info_message(msg) do
    "[INFO]: " <> msg <> "\n"
  end

  defp help_message(msg) do
    "[HELP]: " <> msg <> "\n"
  end

  defp time_message(msg) do
    "[TIME]: " <> msg <> "\n"
  end

  defp error_message(msg) do
    "[ERROR]: " <> msg <> "\n"
  end

  def help do
    help_message("COMMANDS LIST:") <>
      help_message(":h -> Displays this") <>
      help_message(":t -> Displays the remaining time until the chat shuffler") <>
      help_message(":m [message] -> Sends a message") <>
      help_message(":n [new_nick] -> Updates your nickname to [new_nick]") <>
      help_message("To disconnect -> Ctrl+C") <>
      "\n"
  end

  def client_is_not_chatting do
    "You are not chatting with anyone!"
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

  def say_hi_to(%ClientConnection{nickname: nil, pid: pid}) do
    "Say something nice to #{inspect(pid)}!"
    |> info_message
  end

  def say_hi_to(%ClientConnection{nickname: nickname}) do
    "Say something nice to #{nickname}!"
    |> info_message
  end

  def notify_nickname_update(%ClientConnection{nickname: nickname}) do
    "Your nickname is now: #{nickname}"
    |> info_message
  end

  def unknown_command(cmd, args) do
    "Couldn't recognize command '#{Atom.to_string(cmd)}' with arguments '#{args}'"
    |> error_message
  end

  def cannot_execute_command_while_not_chatting do
    "You can't execute this command if you're not chatting!"
    |> error_message
  end

  def time_left(remaining_seconds) do
    "Time left: #{format_time(remaining_seconds)}"
    |> time_message
  end

  defp format_time(remaining_seconds) do
    {:ok, time} = Time.new(0, 0, 0, 0)

    time
    |> Time.add(remaining_seconds)
    |> Time.to_string()
  end

  def client_has_left_the_room(%ClientConnection{nickname: nil, pid: pid}) do
    "#{inspect(pid)} has left the room! Looking for other users..."
    |> info_message
  end

  def client_has_left_the_room(%ClientConnection{nickname: nickname}) do
    "#{nickname} has left the room! Looking for other users..."
    |> info_message
  end

  def inform_looking_for_clients do
    "Looking for users to start chatting!"
    |> info_message
  end
end

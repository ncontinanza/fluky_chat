defmodule Decoder do

  def decode_message(message) do
    message
    |> String.split(" ", parts: 2, trim: true)
    |> if_start_with_atom_then_is_command(message)
  end

  defp if_start_with_atom_then_is_command([_body], complete_message) do
    {:m, complete_message}
  end

  defp if_start_with_atom_then_is_command([maybe_atom, body], complete_message) do
    if String.starts_with?(maybe_atom, ":") do
      {maybe_atom |> String.slice(1..-1) |> String.to_atom, body}
    else
      # If not command, then it is treated like a message
      {:m, complete_message}
    end
  end

end

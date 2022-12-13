defmodule Decoder do
  def decode_message(message) do
    message
    |> String.split(" ", parts: 2, trim: true)
    |> if_start_with_atom_then_is_command(message)
  end

  defp if_start_with_atom_then_is_command([maybe_atom], complete_message) do
    if String.starts_with?(maybe_atom, ":") do
      {maybe_atom |> String.slice(1..-2) |> String.to_atom(), ""}
    else
      # If not command, then it is treated like a message
      {:m, complete_message |> String.slice(0..-2)}
    end
  end

  defp if_start_with_atom_then_is_command([maybe_atom, body], complete_message) do
    if String.starts_with?(maybe_atom, ":") do
      {maybe_atom |> String.slice(1..-1) |> String.to_atom(), body |> String.slice(0..-2)}
    else
      # If not command, then it is treated like a message
      {:m, complete_message |> String.slice(0..-2)}
    end
  end
end

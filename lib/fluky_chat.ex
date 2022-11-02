defmodule FlukyChat do
  @moduledoc """
  Documentation for `FlukyChat`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> FlukyChat.hello()
      :world

  """
  def hello do
    :world
  end

  def main(_args \\ []) do
    IO.puts("hello world")
  end

  def start() do
    port = String.to_integer(System.get_env("PORT") || "4040")

    children = [
      {Task.Supervisor, name: KVServer.TaskSupervisor},
      Supervisor.child_spec({Task, fn -> KVServer.accept(port) end}, restart: :permanent)
    ]

    opts = [strategy: :one_for_one, name: KVServer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

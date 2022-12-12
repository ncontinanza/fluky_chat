defmodule FlukyChat do
  def start() do
    port = String.to_integer(System.get_env("PORT") || "4040")
    # create supervisor process for supervising supervisor child process
    children = [
      {Task.Supervisor, name: KVServer.TaskSupervisor},
      {Task.Supervisor, name: Timer.TaskSupervisor},
      Supervisor.child_spec({Task, fn -> KVServer.accept(port) end}, restart: :permanent)
    ]
    # params for start_link
    opts = [strategy: :one_for_one, name: KVServer.Supervisor]
    # link supervisor and children
    Supervisor.start_link(children, opts)
  end
end

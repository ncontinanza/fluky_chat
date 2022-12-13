defmodule Timer do
  @enforce_keys [:timer_pid, :agent_pid, :init_time, :chat_manager]
  defstruct [:timer_pid, :agent_pid, :init_time, :chat_manager]

  def start(time, chat_manager) do
    {:ok, agent_pid} = Agent.start_link(fn -> time end)
    {:ok, timer_pid} = Task.start(fn -> loop_timer(agent_pid, chat_manager, time) end)

    %Timer{
      timer_pid: timer_pid,
      agent_pid: agent_pid,
      init_time: time,
      chat_manager: chat_manager
    }
  end

  defp loop_timer(pid, chat_manager, init_time) do
    decrement(pid)
    ChatManager.shuffle_clients(chat_manager)
    Agent.update(pid, fn _should_be_zero -> init_time end)
    loop_timer(pid, chat_manager, init_time)
  end

  defp decrement(pid) do
    Process.sleep(1000)

    Agent.get_and_update(pid, fn time -> {time - 1, time - 1} end)
    |> Kernel.then(&(&1 > 0))
    |> Kernel.if(do: decrement(pid))
  end

  def get_time(%Timer{agent_pid: agent_pid}) do
    Agent.get(agent_pid, & &1)
  end

  def restart(%Timer{init_time: init_time, chat_manager: chat_manager}) do
    Timer.start(init_time, chat_manager)
  end
end

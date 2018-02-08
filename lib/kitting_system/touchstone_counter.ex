defmodule KittingSystem.TouchstoneCounter do
  use Agent

  def start_link do
    Agent.start_link(fn -> 2 end, name: __MODULE__)
  end

  def get_id() do
    Agent.get_and_update(__MODULE__, fn state ->
      {state, state+1}
    end)
  end

  def reset() do
    Agent.update(__MODULE__, fn state -> 2 end)
  end
end

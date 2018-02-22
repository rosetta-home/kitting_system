defmodule KittingSystem.Hub do
  use GenServer

  def start_link(id, parent) do
    GenServer.start_link(__MODULE__, {id, parent}, name: __MODULE__)
  end

  def init({id, parent}) do
    Process.send_after(self(), :do_it, 0)
    {:ok, %{id: id, parent: parent}}
  end

  def handle_info(:do_it, state) do
    send(state.parent, {:device, :sd, :hub, :compiling})
    KittingSystem.Compiler.Hub.compile(state.id)
    send(state.parent, {:device, :sd, :hub, :compiled})
    send(state.parent, {:device, :sd, :hub, :flashing})
    KittingSystem.Flash.Hub.flash()
    send(state.parent, {:device, :sd, :hub, :flashed})
    send(state.parent, {:device, :sd, :hub, :complete})
    Process.exit(self(), :normal)
  end

end

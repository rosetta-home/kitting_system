defmodule KittingSystem.Device do
  use GenServer
  alias KittingSystem.Flash.Arduino
  require Logger

  @types %{"1": :gateway, "2": :touchstone}

  defmodule State do
    defstruct [:interface, :device_type, :uart, :fw, :harness, :id]
  end

  def start_link(interface, fw, harness, id) do
    GenServer.start_link(__MODULE__, [interface, fw, harness, id])
  end

  def init([interface, fw, harness, id]) do
    Process.send_after(self(), :init, 0)
    {:ok, %State{interface: interface, fw: fw, harness: harness, id: id}}
  end

  def handle_info(:init, state) do
    Arduino.flash(state.fw, "/dev/#{state.interface}")
    {:ok, pid} = Nerves.UART.start_link()
    :ok = Nerves.UART.open(pid, state.interface, speed: 115200, framing: {Nerves.UART.Framing.Line, separator: "\n"})
    {:noreply, %State{state | uart: pid}}
  end

  def handle_info({:nerves_uart, port, data}, %State{interface: interface} = state) when port == interface do
    Logger.info "#{interface}: #{data}"
    case String.starts_with?(data, "X:") do
      true ->
        Nerves.UART.close(state.uart)
        Nerves.UART.stop(state.uart)
        type = parse_result(data)
        type
        |> compile(state.id)
        |> burn(port)
        send(state.harness, {:device, interface, type, :complete})
        Process.exit(self(), :normal)
      _ -> nil
    end
    {:noreply, state}
  end

  def parse_result(data) do
    [type, temp, g, l, voc, radio] = String.split(data, ",")
    [_, t] = String.split(type, ":")
    Map.get(@types, String.to_existing_atom(t))
  end

  def compile(:gateway, id) do
    KittingSystem.Compiler.Gateway.compile(id)
  end

  def compile(:touchstone, id) do
    KittingSystem.Compiler.Touchstone.compile(id)
  end

  def burn(path, port) do
    Arduino.flash(path, "/dev/#{port}")
  end
end

defmodule KittingSystem.Device do
  use GenServer
  alias KittingSystem.Flash.Arduino
  require Logger

  @types %{"1": :gateway, "2": :touchstone, "0": :failure, "3": :touchstone_partial}

  defmodule State do
    defstruct [:interface, :device_type, :uart, :fw, :harness, :id, num_packets: 0]
  end

  def start_link(interface, fw, harness, id) do
    GenServer.start_link(__MODULE__, [interface, fw, harness, id])
  end

  def init([interface, fw, harness, id]) do
    Process.send_after(self(), :init, 0)
    {:ok, %State{interface: interface, fw: fw, harness: harness, id: id}}
  end

  def handle_info(:init, state) do
    send_feedback(state.harness, state.interface, :verification, :flashing)
    Arduino.flash(state.fw, "/dev/#{state.interface}")
    {:ok, pid} = Nerves.UART.start_link()
    :ok = Nerves.UART.open(pid, state.interface, speed: 115200, framing: {Nerves.UART.Framing.Line, separator: "\n"})
    {:noreply, %State{state | uart: pid}}
  end

  def handle_info({:nerves_uart, port, <<
  "X:", type::binary-size(1), ",",
  "t:", t::binary-size(1), ",",
  "g:", g::binary-size(1), ",",
  "l:", l::binary-size(1), ",",
  "v:", v::binary-size(1), ",",
  "r:", r::binary-size(1)>>},
  %State{interface: interface} = state) when port == interface do
    send_feedback(state.harness, interface, :verification, :flashed)
    Nerves.UART.close(state.uart)
    Nerves.UART.stop(state.uart)
    type = Map.get(@types, String.to_existing_atom(type))
    d = "t=#{t},g=#{g},l=#{l},v=#{v},r=#{r}"
    send_feedback(state.harness, interface, type, "verification:#{d}")
    send_feedback(state.harness, interface, type, :compiling)
    fw = compile(type, state.id, state)
    send_feedback(state.harness, interface, type, :compiled)
    send_feedback(state.harness, interface, type, :flashing)
    burn(fw, port)
    send_feedback(state.harness, interface, type, :flashed)
    send_feedback(state.harness, interface, type, :complete)
    pid =
      case type do
        :gateway ->
          {:ok, pid} = Nerves.UART.start_link()
          Nerves.UART.open(pid, state.interface, speed: 115200, framing: {Nerves.UART.Framing.Line, separator: "\n"})
          pid
        _ -> Process.exit(self(), :normal)
    end
    {:noreply, %State{state | uart: pid, device_type: type}}
  end

  def handle_info({:nerves_uart, port, <<"i:", rest::binary>>}, %State{interface: interface} = state)
  when port == interface do
    d =
      "i:#{rest}"
      |> String.split(",")
      |> Enum.map(fn k -> k |> String.split(":") |> Enum.join("=") end)
      |> Enum.join(",")
    send_feedback(state.harness, interface, :gateway, d)
    total_touchstones = KittingSystem.TouchstoneCounter.get_current()
    #This doesn't account for bad or dead touchstones
    case (state.num_packets + 1) == total_touchstones do
      true ->
        Nerves.UART.close(state.uart)
        Nerves.UART.stop(state.uart)
        Process.exit(self(), :normal)
      _ -> nil
    end
    {:noreply, %State{state | num_packets: state.num_packets + 1}}
  end

  def handle_info({:nerves_uart, port, data}, %State{interface: interface} = state) when port == interface do
    {:noreply, state}
  end

  def handle_info({:nerves_uart, port, data}, state) do
    Logger.info "Got Data: #{inspect port} - #{inspect data}"
    {:noreply, state}
  end

  def send_feedback(pid, interface, type, status) do
    send(pid, {:device, interface, type, status})
  end

  def parse_result(data) do
    [type, temp, g, l, voc, radio] = String.split(data, ",")
    [_, t] = String.split(type, ":")

  end

  def compile(:gateway, id, state) do
    KittingSystem.Compiler.Gateway.compile(id)
  end

  def compile(:touchstone, id, state) do
    KittingSystem.Compiler.Touchstone.compile(id)
  end

  def compile(:failure, id, state) do
    Logger.error("HARDWARE FAILURE ON: #{state.interface}. There should be a device with a red LED illuminated.")
  end

  def compile(:touchstone_partial, id, state) do
    Logger.error("Partial Touchstone failure: #{state.interface}. There should be a device with an Orange LED illuminated.")
  end

  def burn(path, port) do
    case path do
      :ok -> nil
      _ -> Arduino.flash(path, "/dev/#{port}")
    end

  end
end

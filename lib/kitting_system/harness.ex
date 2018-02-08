defmodule KittingSystem.Harness do
  use GenServer
  require Logger
  alias KittingSystem.Flash.Arduino
  alias KittingSystem.Compiler.HardwareVerification

  defmodule State do
    defstruct [devices: %{}, verification_fw: nil]
  end

  def enumerate(id) do
    GenServer.call(__MODULE__, {:enumerate, id})
  end

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    fw = HardwareVerification.compile()
    devices = Nerves.UART.enumerate()
    verify_devices(devices, fw, "Tt-Mh=SQ#dn#JY3_")
    {:ok, %State{devices: devices, verification_fw: fw}}
  end

  def verify_devices(devices, fw, id) do
    devices |> Enum.each(fn {k, device} ->
      KittingSystem.Device.start_link(k, fw, self(), id)
    end)
  end

  def handle_call({:enumerate, id}, _from, state) do
    verify_devices(Nerves.UART.enumerate(), state.verification_fw, id)
    {:reply, }
  end

  def handle_info({:device, port, type, status}, state) do
    Logger.info "Harness got result from #{port} TYPE: #{type} - #{status}"
    {:noreply, state}
  end

  def burn(paths) do
    paths |> Enum.each(fn {fw, interface} ->
      fw |> Arduino.flash(interface)
    end)
    :ok
  end
end

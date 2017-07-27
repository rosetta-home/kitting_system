defmodule KittingSystem.Harness do
  require Logger
  alias KittingSystem.Flash.Arduino

  def enumerate() do
    %{hub: 1, touchstone: 4, gateway: 1}
  end

  def burn(paths) do
    paths |> Enum.each(fn fw ->
      fw |> Arduino.flash("/dev/ttyUSB1")
    end)
    :ok
  end
end

defmodule KittingSystem.Compiler.Touchstone do
  require Logger
  def compile(id, devices) do
    Enum.map(1..devices, fn i ->
      name = "firmware#{i}.ino.hex"
      Logger.debug "Compiling Touchstone ID: #{id} - #{name}"
      System.cmd "docker-compose", [
        "run",
        "arduino-builder",
        "-compile",
        "-hardware", "/opt/arduino/hardware",
        "-tools", "/opt/arduino-builder/tools",
        "-tools", "/opt/arduino/hardware/tools",
        "-libraries", "/data/gateway",
        "-libraries", "/data/ieq",
        "-fqbn", "arduino:avr:uno",
        "-build-path", "/data/firmware/ieq",
        "/code/gateway/firmware.ino"
      ]
      System.cmd("mv", ["priv/firmware/ieq/firmware.ino.hex", "priv/firmware/ieq/#{name}"])
      "priv/firmware/ieq/#{name}"
    end)
  end
end

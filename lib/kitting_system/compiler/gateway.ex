defmodule KittingSystem.Compiler.Gateway do
  require Logger
  def compile(id) do
    Logger.debug "Compiling Gateway ID: #{id}"
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
      "-build-path", "/data/firmware/gateway",
      "/code/gateway/firmware.ino"
    ]
    "priv/firmware/gateway/firmware.ino.hex"
  end
end

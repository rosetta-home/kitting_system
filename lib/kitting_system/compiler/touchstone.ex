defmodule KittingSystem.Compiler.Touchstone do
  require Logger
  def compile(id) do
    Logger.debug "Compiling Touchstone ID: #{id}"
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
      "/code/ieq/firmware.ino"
    ]
  end
end

defmodule KittingSystem.Compiler.HardwareVerification do
  require Logger
  def compile() do
    name = "firmware.ino.hex"
    Logger.debug "Compiling HardwareVerification: #{name}"
    System.cmd "docker-compose", [
      "run",
      "--rm",
      "arduino-builder",
      "-compile",
      "-hardware", "/opt/arduino/hardware",
      "-tools", "/opt/arduino-builder/tools",
      "-tools", "/opt/arduino/hardware/tools",
      "-libraries", "/data/hardware_verification",
      "-fqbn", "arduino:avr:uno",
      "-build-path", "/data/firmware/hardware_verification",
      "/code/hardware_verification/firmware.ino"
    ]
    "priv/firmware/hardware_verification/#{name}"
  end
end

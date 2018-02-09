defmodule KittingSystem.Compiler.HardwareVerification do
  require Logger
  def compile() do
    name = "firmware.ino.hex"
    Logger.debug "Compiling HardwareVerification: #{name}"
    res = System.cmd "docker-compose", [
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
    ],
    stderr_to_stdout: true,
    into: [],
    parallelism: true

    Logger.info "HardwareVerification: #{inspect res}"
    "firmware/hardware_verification/#{name}"
  end
end

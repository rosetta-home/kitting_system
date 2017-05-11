defmodule KittingSystem.Compiler.Touchstone do
  require Logger
  def compile(id) do
    test = "docker-compose run arduino-builder -compile -hardware /opt/arduino/hardware -tools /opt/arduino-builder/tools -tools /opt/arduino/hardware/tools -libraries /data/gateway -libraries /data/ieq -fqbn arduino:avr:uno -build-path /data/firmware/gateway /code/gateway/firmware.ino"
    Logger.debug "Compiling Touchstone ID: #{id}"
    [
      "priv/_compiled/touchstone/#{id}-1.hex",
      "priv/_compiled/touchstone/#{id}-2.hex",
      "priv/_compiled/touchstone/#{id}-3.hex",
      "priv/_compiled/touchstone/#{id}-4.hex"
    ]
  end
end

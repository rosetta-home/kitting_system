defmodule KittingSystem.Flash.Arduino do
  require Logger

  @arduino_type "atmega328p"
  @baud_rate "115200"

  def flash(firmware, interface) do
    fw = Path.join(:code.priv_dir(:kitting_system), firmware)
    res = System.cmd("docker", [
      "run",
      "--rm",
      "-v=#{fw}:/firmware.ino",
      "--device=#{interface}",
      "akshmakov/avrdude",
      "-V",
      "-p#{@arduino_type}",
      "-carduino",
      "-P#{interface}",
      "-b#{@baud_rate}",
      "-Uflash:w:/firmware.ino:i"
    ],
    stderr_to_stdout: true,
    into: [],
    parallelism: true)

    Logger.info "#{inspect res}"
  end
end

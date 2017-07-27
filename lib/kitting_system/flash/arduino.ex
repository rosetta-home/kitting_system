defmodule KittingSystem.Flash.Arduino do
  require Logger

  @arduino_type "atmega328p"
  @baud_rate "115200"

  def flash(firmware, interface) do
    System.cmd("avrdude", [
      "-C/#{:code.priv_dir(:kitting_system)}/avrdude.conf",
      "-v",
      "-p#{@arduino_type}",
      "-carduino",
      "-P#{interface}",
      "b#{@baud_rate}",
      "-D",
      "-Uflash:w:#{firmware}:i"
    ])
  end
end

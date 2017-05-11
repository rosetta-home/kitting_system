defmodule KittingSystem.Compiler.Hub do
  require Logger
  def compile(id) do
    Logger.debug "Compiling Hub ID: #{id}"
    System.cmd "docker-compose", ["run", "nerves-firmware", "mix", "do", "deps.get", ",", "firmware"]
    "priv/firmware/hub/rpi3/fw.fw"
  end
end

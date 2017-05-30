defmodule KittingSystem.Compiler.Hub do
  require Logger
  def compile(id, devices) do
    Enum.map(1..devices, fn i ->
      name = "fw#{i}.fw"
      Logger.debug "Compiling Hub ID: #{id} - #{name}"
      #TODO Generate certificate/verify
      System.cmd "docker-compose", ["run", "nerves-firmware", "mix", "do", "deps.get", ",", "firmware"]
      System.cmd("mv", ["priv/firmware/hub/rpi3/fw.fw", "priv/firmware/hub/rpi3/#{name}"])
      "priv/firmware/hub/rpi3/#{name}"
    end)
  end
end

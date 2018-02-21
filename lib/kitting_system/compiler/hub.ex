defmodule KittingSystem.Compiler.Hub do
  require Logger
  def compile(id) do
    name = "fw.fw"
    Logger.debug "Compiling Hub ID: #{id} - #{name}"
    #TODO Generate certificate/verify
    res = System.cmd(
      "docker-compose",
      ["run", "nerves-firmware",
      "mix", "do", "deps.get", ",", "firmware", ",", "firmware.burn"],
      stderr_to_stdout: true,
      into: [],
      parallelism: true
    )
    Logger.info "#{inspect res}"
    "priv/firmware/hub/#{name}"
  end
end

defmodule KittingSystem.Compiler.Gateway do
  require Logger
  def compile(id) do
    name = "firmware.ino.hex"
    config(1, id)
    Logger.debug "Compiling Gateway ID: #{id} - #{name}"
    res = System.cmd "docker-compose", [
      "run",
      "--rm",
      "arduino-builder",
      "-compile",
      "-hardware", "/opt/arduino/hardware",
      "-tools", "/opt/arduino-builder/tools",
      "-tools", "/opt/arduino/hardware/tools",
      "-libraries", "/data/gateway",
      "-fqbn", "arduino:avr:uno",
      "-build-path", "/data/firmware/gateway",
      "/code/gateway/firmware.ino"
    ],
    into: []
    
    "priv/firmware/gateway/#{name}"
  end

  defp config(id, key) do
    template_path = Path.join(:code.priv_dir(:kitting_system), "build/ieq_config.template")
    output_path = Path.join(:code.priv_dir(:kitting_system), "systems/RFM69-USB-Gateway/firmware/config.h")
    :ok = output_path |> File.write(template_path |> EEx.eval_file([id: id, key: key]))
    output_path
  end
end

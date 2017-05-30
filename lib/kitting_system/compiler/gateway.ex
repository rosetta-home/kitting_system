defmodule KittingSystem.Compiler.Gateway do
  require Logger
  def compile(id, devices) do
    Enum.map(1..devices, fn i ->
      name = "firmware#{i}.ino.hex"
      config(i, id)
      Logger.debug "Compiling Gateway ID: #{id} - #{name}"
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
        "-build-path", "/data/firmware/gateway",
        "/code/gateway/firmware.ino"
      ]
      System.cmd("mv", ["priv/firmware/gateway/firmware.ino.hex", "priv/firmware/gateway/#{name}"])
      "priv/firmware/gateway/#{name}"
    end)
  end

  defp config(id, key) do
    template_path = Path.join(:code.priv_dir(:kitting_system), "build/ieq_config.template")
    output_path = Path.join(:code.priv_dir(:kitting_system), "systems/RFM69-USB-Gateway/firmware/config.h")
    :ok = output_path |> File.write(template_path |> EEx.eval_file([id: id, key: key]))
    output_path
  end
end

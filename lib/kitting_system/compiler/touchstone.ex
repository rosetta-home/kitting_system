defmodule KittingSystem.Compiler.Touchstone do
  require Logger
  def compile(id, devices) do
    Enum.map(2..(devices+1), fn i ->
      name = "firmware#{i}.ino.hex"
      Logger.debug "Compiling Touchstone ID: #{id} - #{name}"
      config(i, id)
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
        "-build-path", "/data/firmware/ieq",
        "/code/ieq/firmware.ino"
      ]
      System.cmd("mv", ["priv/firmware/ieq/firmware.ino.hex", "priv/firmware/ieq/#{name}"])
      "priv/firmware/ieq/#{name}"
    end)
  end

  defp config(id, key) do
    template_path = Path.join(:code.priv_dir(:kitting_system), "build/ieq_config.template")
    output_path = Path.join(:code.priv_dir(:kitting_system), "systems/IndoorAirQualitySensor/firmware/config.h")
    :ok = output_path |> File.write(template_path |> EEx.eval_file([id: id, key: key]))
    output_path
  end
end

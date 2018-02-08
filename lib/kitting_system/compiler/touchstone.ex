defmodule KittingSystem.Compiler.Touchstone do
  require Logger
  def compile(id) do
    num = KittingSystem.TouchstoneCounter.get_id()
    name = "firmware#{num}.ino.hex"
    Logger.debug "Compiling Touchstone ID: #{id} - #{name}"
    config(num, id)
    res = System.cmd "docker-compose", [
      "run",
      "--rm",
      "arduino-builder",
      "-compile",
      "-hardware", "/opt/arduino/hardware",
      "-tools", "/opt/arduino-builder/tools",
      "-tools", "/opt/arduino/hardware/tools",
      "-libraries", "/data/touchstone",
      "-fqbn", "arduino:avr:uno",
      "-build-path", "/data/firmware/touchstone",
      "/code/touchstone/firmware.ino"
    ],
    into: []
    Logger.info("#{inspect res}")
    System.cmd("mv", ["priv/firmware/touchstone/firmware.ino.hex", "priv/firmware/touchstone/#{name}"])
    "priv/firmware/touchstone/#{name}"
  end

  defp config(id, key) do
    template_path = Path.join(:code.priv_dir(:kitting_system), "build/ieq_config.template")
    output_path = Path.join(:code.priv_dir(:kitting_system), "systems/Touchstone/firmware/config.h")
    :ok = output_path |> File.write(template_path |> EEx.eval_file([id: id, key: key]))
    output_path
  end
end

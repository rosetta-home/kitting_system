defmodule KittingSystem.Compiler.Touchstone do
  require Logger
  def compile(id) do
    num = KittingSystem.TouchstoneCounter.get_id()
    o_dir = Path.join(:code.priv_dir(:kitting_system), "systems/Touchstone/firmware/")
    n_dir = Path.join(:code.priv_dir(:kitting_system), "build/touchstone/firmware#{num}/")
    System.cmd("cp", ["-r", o_dir, n_dir])
    System.cmd("mkdir", ["-p", Path.join(:code.priv_dir(:kitting_system), "firmware/touchstone/firmware#{num}")])
    Logger.debug "Compiling Touchstone ID: #{num}"
    config(num, id)
    res = System.cmd "docker-compose", [
      "-p", "touchstone#{num}",
      "run",
      "--rm",
      "arduino-builder",
      "-compile",
      "-hardware", "/opt/arduino/hardware",
      "-tools", "/opt/arduino-builder/tools",
      "-tools", "/opt/arduino/hardware/tools",
      "-libraries", "/data/touchstone",
      "-fqbn", "arduino:avr:uno",
      "-build-path", "/data/firmware/touchstone/firmware#{num}",
      "/build/touchstone/firmware#{num}/firmware.ino"
    ],
    stderr_to_stdout: true,
    into: [],
    parallelism: true

    Logger.info("#{inspect res}")
    "firmware/touchstone/firmware#{num}/firmware.ino.hex"
  end

  defp config(id, key) do
    template_path = Path.join(:code.priv_dir(:kitting_system), "ieq_config.template")
    output_path = Path.join(:code.priv_dir(:kitting_system), "build/touchstone/firmware#{id}/config.h")
    :ok = output_path |> File.write(template_path |> EEx.eval_file([id: id, key: key]))
    output_path
  end
end

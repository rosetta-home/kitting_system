defmodule KittingSystem.Compiler.Gateway do
  require Logger
  def compile(id) do
    files = Path.join(:code.priv_dir(:kitting_system), "systems/RFM69-USB-Gateway/firmware/.")
    n_dir = Path.join(:code.priv_dir(:kitting_system), "build/gateway/firmware1/")
    System.cmd("mkdir", ["-p", n_dir])
    System.cmd("cp", ["-a", files, n_dir])
    System.cmd("mkdir", ["-p", Path.join(:code.priv_dir(:kitting_system), "firmware/gateway/firmware1")])
    Logger.debug "Compiling Gateway ID: 1"
    config(1, id)
    res = System.cmd "docker-compose", [
      "-p", "gateway1",
      "run",
      "--rm",
      "arduino-builder",
      "-compile",
      "-hardware", "/opt/arduino/hardware",
      "-tools", "/opt/arduino-builder/tools",
      "-tools", "/opt/arduino/hardware/tools",
      "-libraries", "/data/gateway",
      "-fqbn", "arduino:avr:uno",
      "-build-path", "/data/firmware/gateway/firmware1",
      "/build/gateway/firmware1/firmware.ino"
    ],
    stderr_to_stdout: true,
    into: [],
    parallelism: true

    Logger.info("#{inspect res}")
    "firmware/gateway/firmware1/firmware.ino.hex"
  end

  defp config(id, key) do
    template_path = Path.join(:code.priv_dir(:kitting_system), "ieq_config.template")
    output_path = Path.join(:code.priv_dir(:kitting_system), "build/gateway/firmware#{id}/config.h")
    :ok = output_path |> File.write(template_path |> EEx.eval_file([id: id, key: key]))
    output_path
  end
end

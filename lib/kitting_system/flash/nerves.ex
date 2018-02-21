defmodule KittingSystem.Flash.Hub do
  require Logger

  def flash(firmware, interface) do
    fw = Path.join(:code.priv_dir(:kitting_system), firmware)
    res = System.cmd("docker-compose", [
      "run",
      "--rm",
      "nerves-firmware",
      "mix",
      "firmware.burn",
      "-d", "/dev/sdc"
    ],
    stderr_to_stdout: true,
    into: [],
    parallelism: true)

    Logger.info "#{inspect res}"
  end
end

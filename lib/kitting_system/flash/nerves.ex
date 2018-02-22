defmodule KittingSystem.Flash.Hub do
  require Logger

  def flash() do
    device = System.cmd("fwup", ["-z"], into: "") |> elem(0) |> String.trim()
    write_certs = Path.join(:code.priv_dir(:kitting_system), "certs/write_certs.sh #{device}")
    Logger.info "Burning hub: #{device}"
    System.put_env("NERVES_DEVICE", device)
    res = System.cmd("docker-compose", [
      "run",
      "--rm",
      "nerves-firmware",
      "mix",
      "firmware.burn",
      "-d", device, "-U"
    ],
    stderr_to_stdout: true,
    into: [],
    parallelism: true)
    Logger.info "#{inspect res}"
    Logger.info "Writing Certs: #{write_certs}"
    res = :os.cmd(write_certs |> String.to_charlist())
    Logger.info "#{inspect res}"
  end
end

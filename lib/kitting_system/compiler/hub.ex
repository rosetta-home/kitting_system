defmodule KittingSystem.Compiler.Hub do
  require Logger
  def compile(id) do
    name = "fw.fw"
    device = System.cmd("fwup", ["-z"], into: "") |> elem(0) |> String.trim()
    System.put_env("NERVES_DEVICE", device)
    Logger.info "Compiling Hub ID: #{id} - #{name}"
    gen_cert = Path.join(:code.priv_dir(:kitting_system), "certs/generate_client_crt.sh #{id}")
    cert = :os.cmd(gen_cert |> String.to_charlist())
    Logger.info "CERT: #{inspect cert}"
    res = System.cmd(
      "docker-compose",
      ["run", "nerves-firmware",
      "mix", "do", "deps.get", ",", "firmware"],
      stderr_to_stdout: true,
      into: [],
      parallelism: true
    )
    Logger.info "#{inspect res}"
    "firmware/hub/#{name}"
  end
end

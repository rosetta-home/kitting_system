defmodule KittingSystem.QRCodeReader do
  require Logger

  def init({:tcp, :http}, req, opts) do
    {:ok, req, %{}}
  end

  def handle(req, state) do
    st = EEx.eval_file(Path.join(:code.priv_dir(:kitting_system), "ui/qr_code_reader.html.eex"), [])
    headers = [
        {"cache-control", "no-cache"},
        {"connection", "close"},
        {"content-type", "text/html"},
        {"expires", "Mon, 3 Jan 2000 12:34:56 GMT"},
        {"pragma", "no-cache"},
        {"Access-Control-Allow-Origin", "*"},
    ]
    {:ok, req2} = :cowboy_req.reply(200, headers, st, req)
    {:ok, req2, state}
  end

  def terminate(_reason, req, state), do: :ok

end

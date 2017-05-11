defmodule KittingSystem.QRCodeCapture do
  require Logger
  alias KittingSystem.{Compiler, Harness}

  @collection "mac_address"

  def init({:tcp, :http}, req, _opts) do
    Process.send_after(self(), :handle, 0)
    {:loop, req, %{}, 30_000}
  end

  def info(:handle, req, state) do
    req
    |> get
    |> verify
    |> compile
    |> burn
    |> reply(state)
  end

  defp get(req) do
    {:ok, kv, req2} = :cowboy_req.body_qs(req)
    Logger.debug "QR Code ID: #{inspect kv}"
    {_key, id} = List.keyfind(kv, "id", 0)
    {req2, id}
  end

  defp verify({req, id}) do
    device =
      KittingSystem.Mongo
      |> Mongo.find_one(
        @collection,
        id |> get_filter,
        pool: DBConnection.Poolboy
      )
    id = device |> Map.get("_id") |> BSON.ObjectId.encode!
    Logger.debug "Got ID: #{id}"
    {req, id}
  end

  defp compile({req, id}) do
    paths = id |> Compiler.Touchstone.compile
    paths = [id |> Compiler.Gateway.compile] ++ paths
    paths = [id |> Compiler.Hub.compile] ++ paths
    {req, paths}
  end

  def burn({req, paths}) do
    paths |> Harness.burn
    {req, paths}
  end

  defp reply({req, paths}, state) do
    Logger.debug "Replying Paths: #{inspect paths}"
    headers = [
      {"cache-control", "no-cache"},
      {"connection", "close"},
      {"content-type", "text/html"},
      {"expires", "Mon, 3 Jan 2000 12:34:56 GMT"},
      {"pragma", "no-cache"},
      {"Access-Control-Allow-Origin", "*"},
    ]
    {:ok, req2} = :cowboy_req.reply(200, headers, paths |> Enum.join(", "), req)
    {:ok, req2, state}
  end

  defp get_filter(id) do
    %{_id: id |> BSON.ObjectId.decode!} |> IO.inspect
  end

  def terminate(_reason, _req, _state), do: :ok

end

defmodule KittingSystem.MacAddressCapture do
  require Logger
  alias KittingSystem.Print

  @collection "mac_address"

  def init({:tcp, :http}, req, _opts) do
    {:ok, req, %{}}
  end

  def handle(req, state) do
    req
    |> get
    |> write
    |> print
    |> reply(state)
  end

  defp get(req) do
    {:ok, kv, req2} = :cowboy_req.body_qs(req)
    Logger.debug "Mac Address: #{inspect kv}"
    {_key, mac_address} = List.keyfind(kv, "mac_address", 0)
    {req2, mac_address}
  end

  defp write({req, mac}) do
    {:ok, device} =
      KittingSystem.Mongo
      |> Mongo.find_one_and_replace(
        @collection,
        mac |> get_filter,
        %{mac_address: mac},
        upsert: true,
        pool: DBConnection.Poolboy,
        return_document: :after
      )
    id = device |> Map.get("_id") |> BSON.ObjectId.encode!
    Logger.debug "Got ID: #{id}"
    {req, id}
  end

  defp print({req, id}) do
    Logger.debug "Printing ID: #{id}"
    id |> Print.compile_template |> Print.send
    {req, id}
  end

  defp reply({req, id}, state) do
    Logger.debug "Replying ID: #{id}"
    headers = [
      {"cache-control", "no-cache"},
      {"connection", "close"},
      {"content-type", "text/html"},
      {"expires", "Mon, 3 Jan 2000 12:34:56 GMT"},
      {"pragma", "no-cache"},
      {"Access-Control-Allow-Origin", "*"},
    ]
    {:ok, req2} = :cowboy_req.reply(200, headers, id, req)
    {:ok, req2, state}
  end

  defp get_filter(mac) do
    %{mac_address: %{"$eq": mac}}
  end

  def terminate(_reason, _req, _state), do: :ok

end

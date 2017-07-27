defmodule KittingSystem.QRCodeCapture do
  require Logger
  alias KittingSystem.{Compiler, Harness}
  alias KittingSystem.Flash.Arduino

  @collection "mac_address"

  def init({:tcp, :http}, req, _opts) do
    {ok, req2} = :cowboy_req.chunked_reply(200, [{"content-type", "text/html"}], req)
    Process.send_after(self(), :handle, 0)
    {:loop, req2, %{}}
  end

  def info(:handle, req, state) do
    req
    |> get
    |> verify
    |> enumerate
    |> compile
    |> burn
    |> reply(state)
  end

  defp get(req) do
    {:ok, kv, req2} = :cowboy_req.body_qs(req)
    Logger.debug "QR Code ID: #{inspect kv}"
    {_key, id} = List.keyfind(kv, "id", 0)
    id = id |> String.downcase
    req2 |> update_status("ID Received: #{id}")
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
    req |> update_status("ID Verified: #{id}")
    {req, id}
  end

  defp enumerate({req, id}) do
    {req, Harness.enumerate, id}
  end

  defp compile({req, hardware, id}) do
    req |> update_status("Compiling Touchstones (#{hardware.touchstone}): #{id}", "")
    paths = id |> Compiler.Touchstone.compile(hardware.touchstone)
    req |> update_status(" - Done")
    req |> update_status("Compiling Gateway (#{hardware.gateway}): #{id}", "")
    paths = (id |> Compiler.Gateway.compile(hardware.gateway)) ++ paths
    req |> update_status(" - Done")
    req |> update_status("Compiling Hub (#{hardware.hub}): #{id}", "")
    req |> keep_alive(20) #nerves compilation takes a bit, cowboy closes the connection if nothing comes through
    paths = (id |> Compiler.Hub.compile(hardware.hub)) ++ paths
    req |> update_status(" - Done")
    {req, paths}
  end

  def burn({req, paths}) do
    req |> update_status("Burning: ", "")
    paths |> Enum.each(fn fw ->
      req |> update_status("Burning: #{fw}", "")
      case fw |> String.ends_with?(".hex") do
        true -> fw |> Arduino.flash("/dev/ttyUSB1")
        false -> :ok
      end
      req |> update_status(" - Done")
    end)
    {req, paths}
  end

  defp reply({req, paths}, state) do
    req |> update_status("All Set!")
    {:ok, req, state}
  end

  defp keep_alive(req, secs) do
    Task.start_link(fn ->
      1..secs |> Enum.each(fn _ ->
        req |> update_status("...", "")
        :timer.sleep(1000)
      end)
    end)
  end

  def update_status(req, status, prepend \\ "\r\n") do
    :cowboy_req.chunk("#{status}#{prepend}", req)
  end

  defp get_filter(id) do
    %{_id: id |> BSON.ObjectId.decode!} |> IO.inspect
  end

  def terminate(_reason, _req, _state), do: :ok

end

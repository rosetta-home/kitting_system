defmodule KittingSystem.QRCodeCapture do
  require Logger
  alias KittingSystem.{Compiler, Harness}
  alias KittingSystem.Flash.Arduino

  @collection "mac_address"

  defmodule State do
    defstruct [num_devices: 0, completed_devices: 0, current_id: 0, num_packets: 0]
  end

  def init({:tcp, :http}, req, _opts) do
    {ok, req2} = :cowboy_req.chunked_reply(200, [{"content-type", "text/html"}], req)
    Process.send_after(self(), :handle, 0)
    {:loop, req2, %State{}, 200_000}
  end

  def info(:handle, req, state) do
    {req, num_devices, id} =
      req
      |> get
      |> verify
      |> enumerate
    Process.send_after(self(), :keep_alive, 1000)
    {:loop, req, %State{state | num_devices: num_devices, current_id: id}}
  end

  def info({:device, port, :gateway, <<"i=", rest::binary>>}, req, state) do
    update_status(req, "#{port}:gateway:complete:i=#{rest}")
    total_touchstones = KittingSystem.TouchstoneCounter.get_current()
    #This doesn't account for bad or dead touchstones
    case (state.num_packets + 1) == total_touchstones do
      true ->
        KittingSystem.TouchstoneCounter.reset()
        reply({req, []}, state)
      _ -> nil
    end
    {:loop, req, %State{state | num_packets: state.num_packets + 1}}
  end

  def info({:device, port, type, :complete}, req, state) do
    update_status(req, "#{port}:#{type}:complete")
    case state.completed_devices == (state.num_devices - 1) do
      true -> update_status(req, "host:waiting_for_data:...")
      false -> nil
    end
    {:loop, req, %State{state | completed_devices: state.completed_devices + 1}}
  end

  def info({:device, port, type, status}, req, state) do
    Logger.info "Web interface got result from #{port} type: #{type} - #{status}"
    update_status(req, "#{port}:#{type}:#{status}")
    {:loop, req, state}
  end

  def info(:keep_alive, req, state) do
    req |> update_status("_:keep_alive")
    Process.send_after(self(), :keep_alive, 1000)
    {:loop, req, state}
  end

  defp get(req) do
    {:ok, kv, req2} = :cowboy_req.body_qs(req)
    Logger.debug "QR Code ID: #{inspect kv}"
    {_key, id} = List.keyfind(kv, "id", 0)
    id = id |> String.downcase
    req2 |> update_status("host:id_received:#{id}")
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
    req |> update_status("host:id_verified:#{id}")
    {req, id}
  end

  defp enumerate({req, id}) do
    {req, Harness.enumerate(id), id}
  end

  defp reply({req, paths}, state) do
    req |> update_status("host:status:complete")
    {:ok, req, state}
  end

  def update_status(req, status, prepend \\ "\r\n") do
    :cowboy_req.chunk("#{status}#{prepend}", req)
  end

  defp get_filter(id) do
    %{_id: id |> BSON.ObjectId.decode!} |> IO.inspect
  end

  def terminate(_reason, _req, _state), do: :ok

end

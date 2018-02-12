defmodule KittingSystem.QRCodeCapture do
  require Logger
  alias KittingSystem.{Compiler, Harness}
  alias KittingSystem.Flash.Arduino

  @collection "mac_address"

  defmodule State do
    defstruct [num_devices: 0, completed_devices: 0, current_id: 0]
  end

  def init({:tcp, :http}, req, _opts) do
    {ok, req2} = :cowboy_req.chunked_reply(200, [{"content-type", "text/html"}], req)
    Process.send_after(self(), :handle, 0)
    {:loop, req2, %State{}}
  end

  def info(:handle, req, state) do
    {req, num_devices, id} =
      req
      |> get
      |> verify
      |> enumerate
      keep_alive(req, 50_000)
    {:loop, req, %State{state | num_devices: num_devices, current_id: id}}
  end

  def info({:device, port, type, :complete}, req, state) do
    completed = state.completed_devices + 1
    case completed >= state.num_devices do
      true -> reply({req, []}, state)
      false ->
        update_status(req, "#{port} - #{type}: complete")
        {:loop, req, %State{state | completed_devices: completed}}
    end
  end

  def info({:device, port, type, status}, req, state) do
    Logger.info "Web interface got result from #{port} type: #{type} - #{status}"
    update_status(req, "#{port} - #{type}: #{status}")
    {:loop, req, state}
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
    {req, Harness.enumerate(id), id}
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

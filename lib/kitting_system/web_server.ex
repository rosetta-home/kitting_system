defmodule KittingSystem.WebServer do

  def start_link do
    configure_mdns
    port = Application.get_env(:kitting_system, :port, "8082") |> String.to_integer
    dispatch = :cowboy_router.compile([
      { :_,
        [
          #{"/", Interface.UI.Index, []},
          {"/mac_address_capture", KittingSystem.MacAddressCapture, []},
          #{"/network", Interface.UI.Network, []},
          #{"/connect_network", Interface.UI.ConnectNetwork, []},
          #{"/reset_network", Interface.UI.ResetNetwork, []},
          #{"/app.js", :cowboy_static, {:priv_file, :interface, "app.js"}},
          #{"/static/[...]", :cowboy_static, {:priv_dir,  :interface, "static"}},

        ]}
      ])
      {:ok, _} = :cowboy.start_http(:interface_http,
        10,
        [{:ip, {0,0,0,0}}, {:port, port}],
        [{:env, [{:dispatch, dispatch}]}]
      )
  end

  def configure_mdns do
    Mdns.Server.add_service(%Mdns.Server.Service{
      domain: "rhks.local",
      data: :ip,
      ttl: 120,
      type: :a
    })
    get_ip |> Mdns.Server.set_ip
    Mdns.Server.start
  end

  def get_ip do
    :inet.getif()
    |> elem(1)
    |> Enum.find(fn
      {ip, {0, 0, 0, 0}, _mask} -> false
      {ip, _gateway, _mask} -> true
    end)
    |> elem(0)
    |> IO.inspect
  end
end

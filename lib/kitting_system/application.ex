defmodule KittingSystem.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      Mongo.child_spec([name: KittingSystem.Mongo, database: "rosetta_home_kitting_system", pool: DBConnection.Poolboy]),
      worker(KittingSystem.WebServer, []),
    ]
    opts = [strategy: :one_for_one, name: KittingSystem.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

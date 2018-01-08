defmodule Mix.Tasks.MongoRestore do
  use Mix.Task
  require Logger

  @shortdoc "Restore mongo from backup"
  @moduledoc """
  Runs docker exec to mongorestore from the backup in ./priv/mongo-backup on the host
  """
  def run(_args) do
    Mix.shell.info "Restoring Kitting System database"
    Mix.shell.cmd("docker exec kittingsystem_mongodb_1 mongorestore /data/backup")
    Mix.shell.info "Restoration complete"
  end

end

defmodule Mix.Tasks.MongoBackup do
  use Mix.Task
  require Logger

  @shortdoc "Create backup of mongo data"
  @moduledoc """
  Runs docker exec to execute a mongodump, then runs docker cp to move data into ./priv/mongo-backup on the host
  """
  def run(_args) do
    Mix.shell.info "Backing up Kitting System database"
    Mix.shell.cmd("docker exec kittingsystem_mongodb_1 mongodump --out /data/backup")
    Mix.shell.info "Backup complete"
  end

end

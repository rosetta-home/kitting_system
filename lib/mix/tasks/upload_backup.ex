defmodule Mix.Tasks.UploadBackup do
  use Mix.Task
  require Logger

  @shortdoc "Upload mongo backup to versioned S3 bucket"
  @moduledoc """
  upload Mongo Backup to S3
  """
  def run(_args) do
    Application.ensure_all_started(:hackney)
    Application.ensure_all_started(:poison)
    dir = :code.priv_dir(:kitting_system)
    Mix.shell.cmd("cd #{dir}/mongo-backup/ && tar zczf #{dir}/mongo-backup.tar.gz *")
    Mix.shell.info "Uploading #{dir}/mongo-backup.tar.gz"
    case ExAws.S3.put_object(
      "kitting-system-backup",
      "mongo-backup.tar.gz",
      File.read!("#{dir}/mongo-backup.tar.gz")
    ) |> ExAws.request!(region: "us-west-2")
    do
        %{status_code: 200} = resp -> Mix.shell.info "Upload complete"
        error -> Mix.shell.error("#{inspect error}")
    end
  end

end

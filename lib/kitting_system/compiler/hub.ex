defmodule KittingSystem.Compiler.Hub do
  require Logger
  def compile(id) do
    Logger.debug "Compiling Hub ID: #{id}"
    "priv/_compiled/hub/#{id}.fw"
  end
end

defmodule KittingSystem.Compiler.Gateway do
  require Logger
  def compile(id) do
    Logger.debug "Compiling Gateway ID: #{id}"
    "priv/_compiled/gateway/#{id}.hex"
  end
end

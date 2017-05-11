defmodule KittingSystem.Compiler.Touchstone do
  require Logger
  def compile(id) do
    Logger.debug "Compiling Touchstone ID: #{id}"
    [
      "priv/firmware/ieq/#{id}-1.ino.hex",
      "priv/firmware/ieq/#{id}-2.ino.hex",
      "priv/firmware/ieq/#{id}-3.ino.hex",
      "priv/firmware/ieq/#{id}-4.ino.hex",
    ]
  end
end

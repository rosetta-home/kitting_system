defmodule KittingSystem.Compiler.Touchstone do
  require Logger
  def compile(id) do
    Logger.debug "Compiling Touchstone ID: #{id}"
    [
      "priv/_compiled/touchstone/#{id}-1.hex",
      "priv/_compiled/touchstone/#{id}-2.hex",
      "priv/_compiled/touchstone/#{id}-3.hex",
      "priv/_compiled/touchstone/#{id}-4.hex"
    ]
  end
end

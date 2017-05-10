defmodule KittingSystem.Harness do
  require Logger
  def burn(paths) do
    Logger.debug "Burning: #{inspect paths}"
    :ok
  end
end

defmodule KittingSystem.Harness do
  require Logger

  def enumerate() do
    %{hub: 1, touchstone: 4, gateway: 1}
  end

  def burn(paths) do
    Logger.debug "Burning: #{inspect paths}"
    :ok
  end
end

defmodule Crow.Helpers do
  @doc """
  Obtain a munin-friendly name for a plugin based on its module name.

  ## Arguments

    - `module`: The module for which a name should be returned.

  ## Examples

      iex> Crow.Helpers.plugin_name(MyApp.CrowPlugins.WebRequests)
      "web_requests"
      iex> Crow.Helpers.plugin_name(MyApp.CrowPlugins.Uptime)
      "uptime"
  """
  @spec plugin_name(module()) :: String.t()
  def plugin_name(module) do
    module
    |> Module.split()
    |> :lists.last()
    |> Macro.underscore()
  end
end

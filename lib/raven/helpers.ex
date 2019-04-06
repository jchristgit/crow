defmodule Raven.Helpers do
  @doc """
  Obtain a munin-friendly name for a plugin based on its module name.

  If the plugin defines `c:Raven.Plugin.name/0`, the result of it is
  used instead.

  ## Arguments

    - `module`: The module for which a name should be returned.

  ## Examples

      iex> Raven.Helpers.plugin_name(MyApp.CrowPlugins.WebRequests)
      'web_requests'
      iex> Raven.Helpers.plugin_name(MyApp.CrowPlugins.Uptime)
      'uptime'
  """
  @spec plugin_name(module()) :: charlist()
  def plugin_name(module) do
    if function_exported?(module, :name, 0) do
      module.name()
    else
      module
      |> Module.split()
      |> :lists.last()
      |> Macro.underscore()
      |> to_charlist()
    end
  end
end

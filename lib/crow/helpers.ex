defmodule Crow.Helpers do
  @moduledoc "Helper functions used across crow."

  @doc """
  Obtain a munin-friendly name for a plugin based on its module name.

  If the plugin defines `c:Crow.Plugin.name/0`, the result of it is
  used instead.

  Note that generating a plugin name for Erlang modules is
  currently not supported.

  ## Arguments

    - `module`: The module for which a name should be returned.

  ## Examples

      iex> Crow.Helpers.plugin_name(MyApp.CrowPlugins.WebRequests)
      'web_requests'
      iex> Crow.Helpers.plugin_name(MyApp.CrowPlugins.Uptime)
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

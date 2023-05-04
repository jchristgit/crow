defmodule Crow.Config do
  @moduledoc """
  Plugin discovery, functions and types for working with plugins.
  """
  @moduledoc since: "0.2.0"

  alias Crow.Plugin

  @typedoc """
  A plugin as appearing in crow's configuration.
  """
  @type configured_plugin :: module() | plugin_with_options()

  @typedoc """
  A plugin along with its options.
  """
  @type plugin_with_options :: {module(), Plugin.options()}

  @doc """
  List all plugins that are configured via crow's `:plugin` app setting.
  """
  def list do
    list(configured())
  end

  @doc """
  List the given plugins along with their options.

  ## Example

  ```elixir
  iex> Crow.Config.list([])
  []
  iex> Crow.Config.list([MyPlugin])
  [{MyPlugin, []}]
  iex> Crow.Config.list([{MyPlugin, mode: :auto}])
  [{MyPlugin, [mode: :auto]}]
  ```
  """
  @spec list(nonempty_list(configured_plugin())) :: [plugin_with_options()]
  def list(plugins) do
    Enum.map(plugins, &into_plugin_with_options/1)
  end

  @doc """
  Find the given plugin under all configured plugins.
  """
  @spec find(nonempty_charlist()) :: plugin_with_options() | nil
  def find(name) do
    find(configured(), name)
  end

  @doc """
  Find a plugin with the given name under the given plugin list.

  Options that were configured with the plugin will be returned with it.
  """
  @spec find(nonempty_list(configured_plugin()), nonempty_charlist()) ::
          plugin_with_options() | nil
  def find(plugins, name) do
    plugins
    |> list()
    |> Enum.find(fn {plugin, options} -> plugin.name(options) == name end)
  end

  @spec into_plugin_with_options(configured_plugin()) :: plugin_with_options()
  defp into_plugin_with_options({plugin, opts} = item) when is_atom(plugin) and is_list(opts),
    do: item

  defp into_plugin_with_options(plugin) when is_atom(plugin), do: {plugin, []}

  @spec configured() :: [configured_plugin()]
  defp configured, do: :application.get_env(:crow, :plugins, [])
end

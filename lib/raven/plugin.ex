defmodule Raven.Plugin do
  @moduledoc """
  The behaviour all configured plugins should implement.
  """

  @doc """
  Display the configuration for this plugin.

  Each element in the output represents a single line in the output.
  Adding newlines to each line is done by the worker.

  For reference, see [Munin plugin config command](http://guide.munin-monitoring.org/en/latest/develop/plugins/howto-write-plugins.html#munin-plugin-config-command)
  from the official guide.

  ## Example

      def config do
        [
          'graph_title Total processes',
          'graph_category BEAM',
          'graph_vlabel processes',
          'processes.label processes'
        ]
      end
  """
  @callback config() :: [charlist()]

  # We need the sigil here to prevent `#{length(:erlang.processes())}`
  # from being evaluated at compilation time, since this is supposed
  # to go into the docs literally.
  @doc ~S"""
  Display values for this plugin.

  ## Example

      def values do
        [
          'processes.value #{length(:erlang.processes())}'
        ]
      end
  """
  @callback values() :: [charlist()]

  @doc """
  Return the name of the plugin displayed to connections.
  By default, a name is generated using `Raven.Helpers.plugin_name/1`.
  """
  @callback name() :: String.t()

  @optional_callbacks [name: 0]
end

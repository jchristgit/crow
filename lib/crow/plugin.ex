defmodule Crow.Plugin do
  @moduledoc """
  The behaviour all configured plugins should implement.

  ## Overview

  Writing [Munin plugins](http://guide.munin-monitoring.org/en/latest/plugin/index.html)
  is rather simple. A trivial plugin with the default
  Munin node setup is a script with two main behaviours:

  - When invoked with the command line argument `config`, print out configuration
    of the plugin, such as graph setup (title, category, labels), field information
    and more. A full description of all options can be found at the [Plugin reference](
    http://guide.munin-monitoring.org/en/latest/reference/plugin.html) documentation.

  - When not invoked with any command line argument, print out the values for fields
    declared in the `config` command.

  This is the foundation from which plugins are developed. Since our node runs in
  the BEAM, we've taken a different approach here. Instead of being executable shell
  scripts, crow plugins are modules which provide three functions:

  - `c:name/1`, which returns the name of the plugin shown to Munin. This must
  be unique amongst all plugins configured on the node.

  - `c:config/1`, which returns the configuration of the plugin, corresponding
  to the first invocation form described above.

  - `c:values/1`, which returns the values of the plugin, corresponding to the
  second invocation form described above.

  These take a single argument, namely the plugin options as specified in the
  crow settings, see `t:options/0`. If your plugin has no configuration
  options, it is safe to ignore this value. Instead of printing to standard
  output, these return a list of charlists which is then sent to the peer via
  TCP.

  ## Community plugins

  Plugins for the crow node can be found in the
  [`crow_plugins`](https://github.com/jchristgit/crow_plugins) repository.
  """

  @typedoc """
  Options passed to the plugin, generally per configuration in `Crow`.

  If no options were passed, this will be an empty list.
  """
  @typedoc since: "0.2.0"
  @type options :: Keyword.t()

  @doc """
  Display the configuration for this plugin.

  Each element in the output represents a single line in the output.
  Adding newlines to each line is done by the worker.

  For reference, see [Munin plugin config command](http://guide.munin-monitoring.org/en/latest/develop/plugins/howto-write-plugins.html#munin-plugin-config-command)
  from the official documentation.

  ## Example

      def config(_opts) do
        [
          'graph_title Total processes',
          'graph_category BEAM',
          'graph_vlabel processes',
          'processes.label processes'
        ]
      end
  """
  @callback config(options()) :: [charlist()]

  @doc """
  Display values for this plugin.

  ## Example

      def values(_opts) do
        [
          'processes.value #\{length(:erlang.processes())\}'
        ]
      end
  """
  @callback values(options()) :: [charlist()]

  @doc """
  Return the name of the plugin displayed to peers.

  ## Example

      def name(_opts) do
        'my_plugin'
      end
  """
  @callback name(options()) :: charlist()
end

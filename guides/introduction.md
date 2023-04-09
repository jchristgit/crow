# Crow

## Overview

Crow provides a Munin node implementation that deals with speaking the Munin
data exchange protocol between the master and nodes. Crow plugins are
implemented as modules following the `Crow.Plugin` behaviour.

## What is Munin?

Quoting [the official website](https://munin-monitoring.org):
> Munin is a networked resource monitoring tool that can help analyze resource trends 
> and "what just happened to kill our performance?" problems. It is designed to be very plug and play.

Munin follows a master-node architecture. The Munin master connects to nodes
which run "plugins" on demand.

In the default Munin installation, a plugin is an executable (this can be a
shell script, Python script, binary...) providing two invocation forms which
print out metadata or graph values. In crow, we use modules instead of
executables. See [Writing plugins](#writing-plugins) and the `Crow.Plugin`
behaviour for more information.

A great overview about the architecture is available at the [Munin's
Architecture](https://munin.readthedocs.io/en/latest/architecture/index.html)

## Writing plugins

Crow plugins are modules implementing the `Crow.Plugin` behaviour.

The following plugin would display a graph of the current process count running
in the BEAM:

```elixir
defmodule MyApp.CrowPlugins.Processes do
  def name do
    'beam_process_count'
  end

  def config do
    [
      'graph_title Total processes',
      'graph_category BEAM',
      'graph_vlabel processes',
      'processes.label processes'
    ]
  end

  def values do
    [
      'processes.value #{length(:erlang.processes())}'
    ]
  end
end
```

The `Crow.Plugin` behaviour contains in-depth documentation of how to write your
plugins. A full reference of plugin output can be found in the [Plugin
reference](http://guide.munin-monitoring.org/en/latest/reference/plugin.html)
document. Additionally, example plugins can be found in the
[`crow_plugins`](https://github.com/jchristgit/crow_plugins) repository.

## Configuration options

The following keys can be set under the `:crow` application key to configure
crow:

- `:plugins` - A list of modules implementing the `Crow.Plugin` behaviour which
  are listed to peers. This value can be changed at runtime and workers will
  pick up the change right away. For example, if you have `crow_plugins`
  installed and want the node to provide information about the BEAM, you could
  set the following:
  ```elixir
  # config/config.exs
  config :crow,
    plugins: [
      CrowPlugins.BEAM.Memory,
      CrowPlugins.BEAM.SystemInfo
    ]
  ```

- `:ip` - The IP address to listen on. This is passed as the `{:ip, ip}` option
  to `:gen_tcp.listen/2`. By default, the node will listen on all network
  interfaces. For example, to only listen on localhost, you could use `{127, 0,
  0, 1}`. This parameter can only be set at application start.

- `:port` - The port to listen on. The default of `4949` matches the munin
  default, but you can change this as you like. This parameter can only be set
  at application start.


<!-- vim: set textwidth=80 sw=2 ts=2: -->

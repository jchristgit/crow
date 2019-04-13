# crow

Crow implements an extensible [Munin](http://munin-monitoring.org/) node in
Elixir. Extensive documentation can be found on https://hexdocs.pm/crow.

## Overview

Crow has an acceptor process that deals with listening to
connections on a configured port (defaulting to `4949`). On connection, a
worker is spawned that speaks the [munin master-node data exchange
protocol](http://guide.munin-monitoring.org/en/latest/master/network-protocol.html#network-protocol).

The worker provides the connected peer with access to plugins, plugins are
modules that implement the `Crow.Plugin` behaviour. The
[`crow_plugins`](https://github.com/jchristgit/crow_plugins) repository contains
a couple of plugins that can be used in monitoring the BEAM itself.

## Installation

You can install `crow` by adding it to your `mix.exs`:

```elixir
def deps do
  [
    {:crow, "~> 0.1"}
  ]
end
```



<!-- vim: set textwidth=80 sw=2 ts=2: -->

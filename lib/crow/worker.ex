defmodule Crow.Worker do
  @moduledoc false
  @version Mix.Project.config()[:version]

  require Logger
  use GenServer

  def start_link([[conn]]) do
    GenServer.start_link(__MODULE__, conn)
  end

  @doc false
  @impl true
  def init(conn) do
    {:ok, conn, {:continue, :send_banner}}
  end

  @doc false
  @impl true
  def handle_continue(:send_banner, conn) do
    {:ok, {ip, port}} = :inet.peername(conn)
    {:ok, hostname} = :inet.gethostname()
    :ok = :gen_tcp.send(conn, '# munin node at #{hostname}\n')
    Logger.info("CONNECT TCP peer #{:inet.ntoa(ip)}:#{port}.")
    {:noreply, conn}
  end

  @doc false
  @impl true
  def handle_info({:tcp, sock, "cap" <> _rest}, state) do
    :ok = :gen_tcp.send(sock, 'cap\n')
    {:noreply, state}
  end

  def handle_info({:tcp, sock, "config " <> rest}, state) do
    plugin_name =
      rest
      |> String.trim()
      |> to_charlist()

    matching_plugin =
      :crow
      |> :application.get_env(:plugins, [])
      |> Stream.map(fn plugin -> {plugin, Crow.Helpers.plugin_name(plugin)} end)
      |> Enum.find(fn {_plugin, name} -> name == plugin_name end)

    if matching_plugin == nil do
      :gen_tcp.send(sock, '# unknown plugin\n')
    else
      {plugin, ^plugin_name} = matching_plugin

      response =
        plugin.config()
        |> Stream.intersperse('\n')
        |> Enum.to_list()
        |> :lists.concat()
        |> :lists.append('\n.\n')

      :ok = :gen_tcp.send(sock, response)
    end

    {:noreply, state}
  end

  def handle_info({:tcp, sock, "fetch " <> rest}, state) do
    plugin_name =
      rest
      |> String.trim()
      |> to_charlist()

    matching_plugin =
      :crow
      |> :application.get_env(:plugins, [])
      |> Stream.map(fn plugin -> {plugin, Crow.Helpers.plugin_name(plugin)} end)
      |> Enum.find(fn {_plugin, name} -> name == plugin_name end)

    if matching_plugin == nil do
      :gen_tcp.send(sock, '# unknown plugin\n.\n')
    else
      {plugin, ^plugin_name} = matching_plugin

      response =
        plugin.values()
        |> Stream.intersperse('\n')
        |> Enum.to_list()
        |> :lists.concat()
        |> :lists.append('\n.\n')

      :ok = :gen_tcp.send(sock, response)
    end

    {:noreply, state}
  end

  def handle_info({:tcp, sock, "list" <> _rest}, state) do
    plugin_line =
      :crow
      |> :application.get_env(:plugins, [])
      |> Stream.map(&Crow.Helpers.plugin_name/1)
      |> Stream.intersperse(' ')
      |> Enum.to_list()
      |> :lists.concat()
      |> :lists.append('\n')

    :ok = :gen_tcp.send(sock, plugin_line)
    {:noreply, state}
  end

  def handle_info({:tcp, sock, "nodes\n"}, state) do
    {:ok, hostname} = :inet.gethostname()
    :ok = :gen_tcp.send(sock, '#{hostname}\n.\n')
    {:noreply, state}
  end

  def handle_info({:tcp, sock, "version\n"}, state) do
    :ok = :gen_tcp.send(sock, 'crow node version #{@version}\n')
    {:noreply, state}
  end

  def handle_info({:tcp, sock, "quit\n"}, state) do
    :ok = :gen_tcp.close(sock)
    Logger.debug("Closed socket due to user command.")
    {:stop, :normal, state}
  end

  def handle_info({:tcp, sock, _message}, state) do
    :ok =
      :gen_tcp.send(
        sock,
        '# unknown command. try cap, config, fetch, list, nodes, version, quit\n'
      )

    {:noreply, state}
  end

  def handle_info({:tcp_closed, _sock}, state) do
    Logger.debug("Peer disconnected.")
    {:stop, :normal, state}
  end
end

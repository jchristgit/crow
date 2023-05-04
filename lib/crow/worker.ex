defmodule Crow.Worker do
  @moduledoc false
  @version Mix.Project.config()[:version]

  alias Crow.Config
  require Logger
  use GenServer

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
    Logger.debug("accepted connection from #{:inet.ntoa(ip)}:#{port}.")
    {:noreply, conn}
  end

  @doc false
  @impl true
  def handle_info({:tcp, sock, "cap" <> _rest}, state) do
    :ok = :gen_tcp.send(sock, 'cap\n')
    {:noreply, state}
  end

  def handle_info({:tcp, sock, "config " <> name}, state) do
    response =
      case find_plugin(name) do
        {plugin, options} ->
          options
          |> plugin.config()
          |> Stream.intersperse('\n')
          |> Enum.to_list()
          |> :lists.concat()
          |> :lists.append('\n.\n')

        nil ->
          '# unknown plugin\n'
      end

    :ok = :gen_tcp.send(sock, response)

    {:noreply, state}
  end

  def handle_info({:tcp, sock, "fetch " <> name}, state) do
    response =
      case find_plugin(name) do
        {plugin, options} ->
          options
          |> plugin.values()
          |> Stream.intersperse('\n')
          |> Enum.to_list()
          |> :lists.concat()
          |> :lists.append('\n.\n')

        nil ->
          '# unknown plugin\n'
      end

    :ok = :gen_tcp.send(sock, response)

    {:noreply, state}
  end

  def handle_info({:tcp, sock, "list" <> _rest}, state) do
    plugin_line =
      Config.list()
      |> Stream.map(fn {plugin, options} -> plugin.name(options) end)
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

  # We do not really care about the rest of the command here.
  def handle_info({:tcp, sock, "quit" <> _rest}, state) do
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

  @spec find_plugin(String.t()) :: Config.plugin_with_options() | nil
  defp find_plugin(name) do
    name
    |> String.trim()
    |> to_charlist()
    |> Config.find()
  end
end

defmodule Crow.Node do
  @moduledoc false

  require Logger
  use GenServer

  def start_link(options) do
    GenServer.start_link(__MODULE__, options)
  end

  @doc false
  def init(_options) do
    ip = :application.get_env(:crow, :ip, nil)
    port = :application.get_env(:crow, :port, 4949)

    listen_opts =
      if ip == nil do
        [:binary, {:reuseaddr, true}]
      else
        [:binary, {:reuseaddr, true}, {:ip, ip}]
      end

    case :gen_tcp.listen(port, listen_opts) do
      {:ok, sock} ->
        Logger.debug("Listening for connections on port `#{port}`.")

        {:ok, sock, {:continue, 1}}

      {:error, reason} ->
        {:error, {:cannot_open_socket, reason}}
    end
  end

  def handle_continue(connection_count, sock) do
    {:ok, conn} = :gen_tcp.accept(sock)

    {:ok, worker} = GenServer.start(Crow.Worker, conn)

    :ok = :gen_tcp.controlling_process(conn, worker)
    Logger.debug("Accepted connection ##{connection_count} on worker #{inspect(worker)}.")
    {:noreply, sock, {:continue, connection_count + 1}}
  end
end

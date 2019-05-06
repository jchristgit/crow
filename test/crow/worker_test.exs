defmodule Crow.WorkerTest do
  use ExUnit.Case

  defmodule TestPlugin do
    def name, do: 'custom_name'
    def config, do: ['graph_title fizz buzz']
    def values, do: ['foo.value 3']
  end

  setup_all do
    :application.set_env(:crow, :plugins, [TestPlugin])
  end

  setup do
    {:ok, socket} = :gen_tcp.connect({127, 0, 0, 1}, 4949, [:binary])
    {:ok, hostname} = :inet.gethostname()
    expected_message = "# munin node at #{hostname}\n"
    assert_receive {:tcp, ^socket, ^expected_message}
    [socket: socket]
  end

  describe "on initial connection" do
    test "displays the banner" do
      {:ok, socket} = :gen_tcp.connect({127, 0, 0, 1}, 4949, [:binary])
      {:ok, hostname} = :inet.gethostname()
      expected_message = "# munin node at #{hostname}\n"
      assert_receive {:tcp, ^socket, ^expected_message}
    end
  end

  describe "cap command" do
    test "displays no capabilities", %{socket: socket} do
      :ok = :gen_tcp.send(socket, 'cap\n')
      assert_receive {:tcp, ^socket, "cap\n"}
    end
  end

  describe "config command" do
    test "displays configuration for known plugins", %{socket: socket} do
      :ok = :gen_tcp.send(socket, 'config custom_name\n')
      assert_receive {:tcp, ^socket, "graph_title fizz buzz\n.\n"}
    end

    test "displays unknown plugin for unknown plugins", %{socket: socket} do
      :ok = :gen_tcp.send(socket, 'config totally_not_a_plugin\n')
      assert_receive {:tcp, ^socket, "# unknown plugin\n"}
    end
  end

  describe "fetch command" do
    test "displays values for known plugins", %{socket: socket} do
      :ok = :gen_tcp.send(socket, 'fetch custom_name\n')
      assert_receive {:tcp, ^socket, "foo.value 3\n.\n"}
    end

    test "displays unknown plugin for unknown plugins", %{socket: socket} do
      :ok = :gen_tcp.send(socket, 'fetch totally_not_a_plugin\n')
      assert_receive {:tcp, ^socket, "# unknown plugin\n.\n"}
    end
  end

  describe "list command" do
    test "displays the configured test plugin", %{socket: socket} do
      :ok = :gen_tcp.send(socket, 'list\n')
      assert_receive {:tcp, ^socket, "custom_name\n"}
    end
  end

  describe "nodes command" do
    test "displays the local node hostname", %{socket: socket} do
      :ok = :gen_tcp.send(socket, 'nodes\n')
      {:ok, hostname} = :inet.gethostname()
      expected_message = "#{hostname}\n.\n"
      assert_receive {:tcp, ^socket, ^expected_message}
    end
  end

  describe "version command" do
    test "displays the current version", %{socket: socket} do
      :ok = :gen_tcp.send(socket, 'version\n')
      expected_message = "crow node version #{Mix.Project.config()[:version]}\n"
      assert_receive {:tcp, ^socket, ^expected_message}
    end
  end

  describe "quit command" do
    test "closes the connection", %{socket: socket} do
      :ok = :gen_tcp.send(socket, 'quit\n')
      assert_receive {:tcp_closed, ^socket}
    end
  end

  describe "unknown commands" do
    test "display help", %{socket: socket} do
      :ok = :gen_tcp.send(socket, 'totally_not_a_command\n')

      assert_receive {:tcp, ^socket,
                      "# unknown command. try cap, config, fetch, list, nodes, version, quit\n"}
    end
  end
end

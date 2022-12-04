defmodule FlukyChat.ActiveClientsTest do
  use ExUnit.Case

  describe "Active Clients" do
    test "Empty? ActiveClients" do
      acl = ActiveClients.start()
      assert ActiveClients.empty?(acl)
    end
    test "Not Empty? ActiveClients" do
      acl = ActiveClients.start()
      ActiveClients.add_client(acl, %ClientConnection{pid: 1, socket: :socket})
      refute ActiveClients.empty?(acl)
    end
    test "Add a client to ActiveClients" do
      acl = ActiveClients.start()
      ActiveClients.add_client(acl, %ClientConnection{pid: 1, socket: :socket})
      assert %ClientConnection{pid: 1, socket: :socket} == ActiveClients.get_client(acl, 1)
    end
    test "Add and remove a client to ActiveClients" do
      acl = ActiveClients.start()
      ActiveClients.add_client(acl, %ClientConnection{pid: 1, socket: :socket})
      assert %ClientConnection{pid: 1, socket: :socket} == ActiveClients.get_client(acl, 1)
      ActiveClients.remove_client(acl, 1)
      assert ActiveClients.empty?(acl)
    end
    test "Add multiple clients to ActiveClients and remove one of them" do
      acl = ActiveClients.start()
      ActiveClients.add_client(acl, %ClientConnection{pid: 1, socket: :socket})
      ActiveClients.add_client(acl, %ClientConnection{pid: 2, socket: :socket})
      ActiveClients.add_client(acl, %ClientConnection{pid: 3, socket: :socket})
      ActiveClients.add_client(acl, %ClientConnection{pid: 4, socket: :socket})
      ActiveClients.remove_client(acl, 3)
      refute ActiveClients.empty?(acl)
      assert ActiveClients.length(acl) == 3
      assert %ClientConnection{pid: 1, socket: :socket} == ActiveClients.get_client(acl, 1)
      assert %ClientConnection{pid: 2, socket: :socket} == ActiveClients.get_client(acl, 2)
      assert %ClientConnection{pid: 4, socket: :socket} == ActiveClients.get_client(acl, 4)
    end
  end
end

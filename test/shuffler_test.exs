defmodule FlukyChat.ShufflerTest do
  use ExUnit.Case

  describe "Shuffler" do
    test "Shuffle an empty ActiveClients returns an empty ActiveClients" do
      shuffled_empty_acl = Shuffler.start() |> Shuffler.shuffle(ActiveClients.start())
      assert ActiveClients.empty?(shuffled_empty_acl)
    end

    test "Shuffle an ActiveClients with a single pair of clients returns the same ActiveClients" do
      shuffler = Shuffler.start()
      acl = ActiveClients.start()
      ActiveClients.add_client(acl, 1, :socket)
      ActiveClients.add_client(acl, 2, :other_socket)

      :ok = Shuffler.shuffle(shuffler, acl)

      assert Shuffler.get_client_pair(shuffler, 1) == 2
      assert Shuffler.get_client_pair(shuffler, 2) == 1
    end

    test "Shuffle an ActiveClients with a multiple pairs of clients shuffles the clients" do
      shuffler = Shuffler.start()
      acl = ActiveClients.start()
      ActiveClients.add_client(acl, 1, :socket)
      ActiveClients.add_client(acl, 2, :socket)
      ActiveClients.add_client(acl, 3, :socket)
      ActiveClients.add_client(acl, 4, :socket)
      ActiveClients.add_client(acl, 5, :socket)
      ActiveClients.add_client(acl, 6, :socket)

      :ok = Shuffler.shuffle(shuffler, acl)

      assert Shuffler.get_client_pair(shuffler, 1) != 1
      assert Shuffler.get_client_pair(shuffler, 2) != 2
      assert Shuffler.get_client_pair(shuffler, 3) != 3
      assert Shuffler.get_client_pair(shuffler, 4) != 4
      assert Shuffler.get_client_pair(shuffler, 5) != 5
      assert Shuffler.get_client_pair(shuffler, 6) != 6
    end
  end
end

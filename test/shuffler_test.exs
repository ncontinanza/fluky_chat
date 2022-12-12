defmodule FlukyChat.ShufflerTest do
  use ExUnit.Case

  describe "Shuffler" do
    '''
    test "Shuffle an empty ActiveClients returns an empty ActiveClients" do
      shuffled_empty_acl = Shuffler.start() |> Shuffler.shuffle(ActiveClients.start() |> ActiveClients.get_all_clients)
      assert ActiveClients.empty?(shuffled_empty_acl)
    end
    '''

    test "Shuffle an ActiveClients with a single pair of clients returns the same ActiveClients" do
      shuffler = Shuffler.start()
      acl = ActiveClients.start()
      ActiveClients.add_client(acl, %ClientConnection{pid: 1, socket: :socket})
      ActiveClients.add_client(acl, %ClientConnection{pid: 2, socket: :other_socket})

      {:ok, :nil} = Shuffler.shuffle(shuffler, ActiveClients.get_all_clients(acl))

      assert Shuffler.get_client_pair(shuffler, 1) == 2
      assert Shuffler.get_client_pair(shuffler, 2) == 1
    end

    test "Shuffle an ActiveClients with a multiple pairs of clients shuffles the clients" do
      shuffler = Shuffler.start()
      acl = ActiveClients.start()
      ActiveClients.add_client(acl, %ClientConnection{pid: 1, socket: :socket})
      ActiveClients.add_client(acl, %ClientConnection{pid: 2, socket: :socket})
      ActiveClients.add_client(acl, %ClientConnection{pid: 3, socket: :socket})
      ActiveClients.add_client(acl, %ClientConnection{pid: 4, socket: :socket})
      ActiveClients.add_client(acl, %ClientConnection{pid: 5, socket: :socket})
      ActiveClients.add_client(acl, %ClientConnection{pid: 6, socket: :socket})

      {:ok, :nil} = Shuffler.shuffle(shuffler, ActiveClients.get_all_clients(acl))

      assert Shuffler.get_client_pair(shuffler, 1) != 1
      assert Shuffler.get_client_pair(shuffler, 2) != 2
      assert Shuffler.get_client_pair(shuffler, 3) != 3
      assert Shuffler.get_client_pair(shuffler, 4) != 4
      assert Shuffler.get_client_pair(shuffler, 5) != 5
      assert Shuffler.get_client_pair(shuffler, 6) != 6
    end

    test "Shuffle an ActiveClients with an odd amount of clients makes the shuffler return one" do
      shuffler = Shuffler.start()
      acl = ActiveClients.start()
      ActiveClients.add_client(acl, %ClientConnection{pid: 1, socket: :socket})
      ActiveClients.add_client(acl, %ClientConnection{pid: 2, socket: :other_socket})
      ActiveClients.add_client(acl, %ClientConnection{pid: 3, socket: :another_one})

      {result, _} = Shuffler.shuffle(shuffler, ActiveClients.get_all_clients(acl))

      assert result == :one_left
    end

  end
end

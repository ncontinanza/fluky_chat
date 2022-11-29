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
      shuffled_list = Shuffler.shuffle(shuffler, acl)
      refute ActiveClients.empty?(shuffled_list)
    end

    # TODO: qué pasa cuando hay un solo cliente en ActiveClients?
    # Actualmente crashea cuando se intenta hacer un shuffle
  end
end

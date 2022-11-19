defmodule FlukyChatTest do
  use ExUnit.Case
  doctest FlukyChat

  test "greets the world" do
    assert FlukyChat.hello() == :world
  end
end

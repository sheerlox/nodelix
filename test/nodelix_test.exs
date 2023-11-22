defmodule NodelixTest do
  use ExUnit.Case
  doctest Nodelix

  test "greets the world" do
    assert Nodelix.hello() == :world
  end
end

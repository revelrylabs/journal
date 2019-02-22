defmodule JournalTest do
  use ExUnit.Case
  doctest Journal

  test "greets the world" do
    assert Journal.hello() == :world
  end
end

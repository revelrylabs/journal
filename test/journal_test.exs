defmodule JournalTest do
  use ExUnit.Case, async: true
  doctest Journal

  setup_all do
    {:ok, _} = Journal.Memory.start_link()

    :ok
  end

  test "put and get" do
    Journal.Memory.put("hello", "there")
    assert Journal.Memory.get("hello") == {:ok, "there"}
  end

  test "put and get version" do
    Journal.Memory.put("hello", "there")
    assert Journal.Memory.get("hello") == {:ok, "there"}

    Journal.Memory.put("hello", "the")
    assert Journal.Memory.get("hello") == {:ok, "the"}

    assert Journal.Memory.get("hello", 0) == {:ok, "there"}

    assert Journal.Memory.version_count("hello") == 2
  end

  test "delete" do
    Journal.Memory.put("hello", "there")
    Journal.Memory.delete("hello")

    assert Journal.Memory.get("hello") == {:ok, nil}
  end
end

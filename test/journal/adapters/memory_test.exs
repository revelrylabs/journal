defmodule Journal.Adapters.MemoryTest do
  use ExUnit.Case, async: true

  setup_all do
    {:ok, _} = Journal.Memory.start_link()

    :ok
  end

  test "put and get" do
    Journal.Memory.put("hello", "there")
    assert {:ok, %Journal.Entry{data: "there"}} = Journal.Memory.get("hello")
  end

  test "put and get version" do
    Journal.Memory.put("hello", "there")
    assert {:ok, %Journal.Entry{data: "there"}} = Journal.Memory.get("hello")

    Journal.Memory.put("hello", "the")
    assert {:ok, %Journal.Entry{data: "the"}} = Journal.Memory.get("hello")

    assert {:ok, %Journal.Entry{data: "there"}} = Journal.Memory.get("hello", 0)

    assert Journal.Memory.versions("hello") |> elem(1) |> length > 1
  end

  test "delete" do
    assert :ok = Journal.Memory.delete("hello")
    assert {:error, %Journal.Error{error: "key not found"}} = Journal.Memory.get("hello")
  end
end

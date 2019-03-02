defmodule Journal.Adapters.IPFSTest do
  use ExUnit.Case, async: true

  setup_all do
    Application.put_env(:journal, Journal.IPFS, url: "http://localhost:5001")
    {:ok, _} = Journal.IPFS.start_link()

    :ok
  end

  test "put and get" do
    Journal.IPFS.put("/hello/test.txt", "there")
    assert {:ok, %Journal.Entry{data: "there"}} = Journal.IPFS.get("/hello/test.txt")
  end

  test "put and get version" do
    Journal.IPFS.put("/hello/test.txt", "there")
    assert {:ok, %Journal.Entry{data: "there"}} = Journal.IPFS.get("/hello/test.txt")

    Journal.IPFS.put("/hello/test.txt", "the")
    assert {:ok, %Journal.Entry{data: "the"}} = Journal.IPFS.get("/hello/test.txt")

    assert {:ok, %Journal.Entry{data: "there"}} = Journal.IPFS.get("/hello/test.txt", 0)

    assert Journal.IPFS.versions("/hello/test.txt") |> elem(1) |> length() > 1
  end

  test "delete" do
    Journal.IPFS.put("/hello/test.txt", "there")
    Journal.IPFS.delete("/hello/test.txt")

    assert {:error, %Journal.Error{}} = Journal.IPFS.get("/hello/test.txt")
  end
end

defmodule Journal.Adapters.IPFSTest do
  use ExUnit.Case, async: true

  setup_all do
    Application.put_env(:journal, Journal.IPFS, url: "http://localhost:5001")
    {:ok, _} = Journal.IPFS.start_link()

    :ok
  end

  test "put and get" do
    Journal.IPFS.put("/hello/test.txt", "there")
    assert Journal.IPFS.get("/hello/test.txt") == {:ok, "there"}
  end

  test "put and get version" do
    Journal.IPFS.put("/hello/test.txt", "there")
    assert Journal.IPFS.get("/hello/test.txt") == {:ok, "there"}

    Journal.IPFS.put("/hello/test.txt", "the")
    assert Journal.IPFS.get("/hello/test.txt") == {:ok, "the"}

    assert Journal.IPFS.get("/hello/test.txt", 0) == {:ok, "there"}

    assert Journal.IPFS.version_count("/hello/test.txt") > 1
  end

  test "delete" do
    Journal.IPFS.put("/hello/test.txt", "there")
    Journal.IPFS.delete("/hello/test.txt")

    assert Journal.IPFS.get("/hello/test.txt") == nil
  end
end

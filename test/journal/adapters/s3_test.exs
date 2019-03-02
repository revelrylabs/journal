defmodule Journal.Adapters.S3Test do
  use ExUnit.Case, async: true

  setup_all do
    Application.put_env(:journal, Journal.S3, bucket: "revelry-journal-test")
    {:ok, _} = Journal.S3.start_link()

    :ok
  end

  test "put and get" do
    Journal.S3.put("/hello/test.txt", "there")
    assert {:ok, %Journal.Entry{data: "there"}} = Journal.S3.get("/hello/test.txt")
  end

  test "put and get version" do
    Journal.S3.put("/hello/test.txt", "there")

    assert {:ok, %Journal.Entry{data: "there", version: version}} =
             Journal.S3.get("/hello/test.txt")

    Journal.S3.put("/hello/test.txt", "the")
    assert {:ok, %Journal.Entry{data: "the"}} = Journal.S3.get("/hello/test.txt")

    assert Journal.S3.versions("/hello/test.txt") |> elem(1) |> length() > 1

    assert {:ok, %Journal.Entry{data: "there"}} = Journal.S3.get("/hello/test.txt", version)
  end

  test "delete" do
    Journal.S3.put("/hello/test.txt", "there")
    Journal.S3.delete("/hello/test.txt")

    assert {:error, %Journal.Error{}} = Journal.S3.get("/hello/test.txt")
  end
end

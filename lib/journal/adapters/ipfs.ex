defmodule Journal.Adapters.IPFS do
  @behaviour Journal.Adapter
  @moduledoc """
  IPFS adapter for Journal
  """
  alias Journal.Adapters.IPFS.API

  def init(config) do
    meta = %{
      url: config[:url] <> "/api/v0"
    }

    {:ok, nil, meta}
  end

  def put(%{url: url}, key, value) do
    API.file_write(url, key, value)
  end

  def get(%{url: url}, key) do
    API.file_read(url, key)
  end

  def get(%{url: url}, key, _version) do
    API.file_read(url, key)
  end

  def version_count(%{url: _url}, _key) do
    0
  end

  def delete(%{url: url}, key) do
    API.file_delete(url, key)

    :ok
  end
end

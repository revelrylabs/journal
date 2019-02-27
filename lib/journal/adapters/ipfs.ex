defmodule Journal.Adapters.IPFS do
  @behaviour Journal.Adapter
  @moduledoc """
  IPFS adapter for Journal

  The url to the IPFS instance is required

    config :journal, MyApp.Journal, url: "http://localhost:5001"

  """
  alias Journal.Adapters.IPFS.API
  @dag_path "/.journal.adapters.ipfs"

  def init(config) do
    meta = %{
      url: config[:url] <> "/api/v0"
    }

    {:ok, nil, meta}
  end

  def put(%{url: url}, key, value) do
    case get_dag_hash(url, key) do
      nil ->
        dag = %{}

        API.file_write(url, key, value)
        {:ok, %{"Hash" => hash}} = API.file_stat(url, key)

        dag =
          Map.put(dag, "version0", %{
            "content" => %{"/" => hash}
          })

        {:ok, %{"Cid" => %{"/" => ipfs_dag_hash}}} = API.dag_put(url, dag)

        API.file_write(url, Path.join(@dag_path, key), ipfs_dag_hash)

      ipfs_dag_hash ->
        {:ok, dag} = API.dag_get(url, ipfs_dag_hash)

        API.file_write(url, key, value)
        {:ok, %{"Hash" => hash}} = API.file_stat(url, key)

        next_version = dag |> Map.keys() |> length()

        dag =
          Map.put(dag, "version#{next_version}", %{
            "content" => %{"/" => hash}
          })

        {:ok, %{"Cid" => %{"/" => ipfs_dag_hash}}} = API.dag_put(url, dag)

        API.file_write(url, Path.join(@dag_path, key), ipfs_dag_hash)
    end
  end

  def get(%{url: url}, key) do
    case API.file_read(url, key) do
      {:error, %{"Message" => "file does not exist"}} ->
        nil

      ok ->
        ok
    end
  end

  def get(%{url: url}, key, version) do
    case get_dag_hash(url, key) do
      nil ->
        nil

      ipfs_dag_hash ->
        API.cat(url, "#{ipfs_dag_hash}/version#{version}/content")
    end
  end

  def version_count(%{url: url}, key) do
    case get_dag_hash(url, key) do
      nil ->
        0

      ipfs_dag_hash ->
        {:ok, dag} = API.dag_get(url, ipfs_dag_hash)
        dag |> Map.keys() |> length()
    end
  end

  def delete(%{url: url}, key) do
    case get_dag_hash(url, key) do
      nil ->
        nil

      _ ->
        API.file_delete(url, Path.join(@dag_path, key))
        API.file_delete(url, key)
    end

    :ok
  end

  defp get_dag_hash(url, key) do
    dag_hash_path = Path.join(@dag_path, key)

    case API.file_read(url, dag_hash_path) do
      {:error, %{"Message" => "file does not exist"}} ->
        nil

      {:ok, ipfs_dag_hash} ->
        ipfs_dag_hash
    end
  end
end

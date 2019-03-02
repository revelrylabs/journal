defmodule Journal.Adapters.IPFS do
  @behaviour Journal.Adapter
  @moduledoc """
  IPFS adapter for Journal

  The url to the IPFS instance is required

    config :journal, MyApp.Journal, url: "http://localhost:5001"

  """
  alias Journal.Adapters.IPFS.API
  @dag_path "/.journal.adapters.ipfs"
  alias Journal.{Entry, Error}

  def init(config) do
    meta = %{
      url: config[:url] <> "/api/v0"
    }

    {:ok, nil, meta}
  end

  def put(%{url: url}, key, value) do
    case get_dag_hash(url, key) do
      {:error, _error} ->
        dag = %{}

        API.file_write(url, key, value)
        {:ok, %{"Hash" => hash}} = API.file_stat(url, key)

        dag =
          Map.put(dag, "version0", %{
            "content" => %{"/" => hash}
          })

        {:ok, %{"Cid" => %{"/" => ipfs_dag_hash}}} = API.dag_put(url, dag)

        case API.file_write(url, Path.join(@dag_path, key), ipfs_dag_hash) do
          {:error, error} ->
            {:error,
             %Error{
               key: key,
               error: error
             }}

          {:ok, _} ->
            {:ok,
             %Entry{
               key: key,
               data: value,
               version: 0,
               timestamp: nil
             }}
        end

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

        case API.file_write(url, Path.join(@dag_path, key), ipfs_dag_hash) do
          {:error, error} ->
            {:error,
             %Error{
               key: key,
               error: error
             }}

          {:ok, _} ->
            {:ok,
             %Entry{
               key: key,
               data: value,
               version: next_version,
               timestamp: nil
             }}
        end
    end
  end

  def get(%{url: url}, key) do
    case API.file_read(url, key) do
      {:error, error} ->
        {:error,
         %Error{
           key: key,
           error: error
         }}

      {:ok, data} ->
        {:ok,
         %Entry{
           key: key,
           data: data,
           version: nil,
           timestamp: nil
         }}
    end
  end

  def get(%{url: url}, key, version) do
    case get_dag_hash(url, key) do
      {:error, error} ->
        {:error,
         %Error{
           key: key,
           error: error
         }}

      ipfs_dag_hash ->
        {:ok, data} = API.cat(url, "#{ipfs_dag_hash}/version#{version}/content")

        {:ok,
         %Entry{
           key: key,
           data: data,
           version: version,
           timestamp: nil
         }}
    end
  end

  def versions(%{url: url}, key) do
    case get_dag_hash(url, key) do
      {:error, error} ->
        {:error,
         %Error{
           key: key,
           error: error
         }}

      ipfs_dag_hash ->
        {:ok, dag} = API.dag_get(url, ipfs_dag_hash)

        versions =
          dag
          |> Map.keys()
          |> Enum.map(fn dag_key ->
            %Entry{
              key: key,
              data: nil,
              version: String.replace(dag_key, "version", ""),
              timestamp: nil
            }
          end)

        {:ok, versions}
    end
  end

  def delete(%{url: url}, key) do
    case get_dag_hash(url, key) do
      {:error, error} ->
        {:error,
         %Error{
           key: key,
           error: error
         }}

      _ ->
        API.file_delete(url, Path.join(@dag_path, key))
        API.file_delete(url, key)
        :ok
    end
  end

  defp get_dag_hash(url, key) do
    dag_hash_path = Path.join(@dag_path, key)

    case API.file_read(url, dag_hash_path) do
      {:error, _} = error ->
        error

      {:ok, ipfs_dag_hash} ->
        ipfs_dag_hash
    end
  end
end

defmodule Journal.Adapters.S3 do
  @behaviour Journal.Adapter
  @moduledoc """
  S3 adapter for Journal

  The name of the S3 bucket is required

    config :journal, MyApp.Journal, bucket: "my-bucket"

  **NOTE**: The bucket must has versioning enabled.

  Uses ex_aws to interact with AWS S3. The default config
  for find keys is:

    config :ex_aws,
      access_key_id: [{:system, "AWS_ACCESS_KEY_ID"}, :instance_role],
      secret_access_key: [{:system, "AWS_SECRET_ACCESS_KEY"}, :instance_role]

  This can be changed in your config.
  """
  alias ExAws.S3
  alias Journal.{Entry, Error}

  def init(config) do
    meta = %{
      bucket: config[:bucket]
    }

    {:ok, nil, meta}
  end

  def put(%{bucket: bucket}, key, value) do
    response = S3.put_object(bucket, key, value) |> ExAws.request()

    case response do
      {:ok, data} ->
        {:ok,
         %Entry{
           key: key,
           data: value,
           version: List.keyfind(data.headers, "x-amz-version-id", 0, {:noop, nil}) |> elem(1),
           timestamp: List.keyfind(data.headers, "Last-Modified", 0, {:noop, nil}) |> elem(1)
         }}

      {:error, error} ->
        {:error,
         %Error{
           key: key,
           error: error
         }}
    end
  end

  def get(%{bucket: bucket}, key) do
    response = S3.get_object(bucket, key) |> ExAws.request()

    case response do
      {:ok, %{body: body} = data} ->
        {:ok,
         %Entry{
           key: key,
           data: body,
           version: List.keyfind(data.headers, "x-amz-version-id", 0, {:noop, nil}) |> elem(1),
           timestamp: List.keyfind(data.headers, "Last-Modified", 0, {:noop, nil}) |> elem(1)
         }}

      {:error, error} ->
        {:error,
         %Error{
           key: key,
           error: error
         }}
    end
  end

  def get(%{bucket: bucket}, key, version) do
    response = S3.get_object(bucket, key <> "?versionId=#{version}") |> ExAws.request()

    case response do
      {:ok, %{body: body} = data} ->
        {:ok,
         %Entry{
           key: key,
           data: body,
           version: List.keyfind(data.headers, "x-amz-version-id", 0, {:noop, nil}) |> elem(1),
           timestamp: List.keyfind(data.headers, "Last-Modified", 0, {:noop, nil}) |> elem(1)
         }}

      {:error, error} ->
        {:error,
         %Error{
           key: key,
           error: error
         }}
    end
  end

  def versions(%{bucket: bucket}, key) do
    import SweetXml

    {:ok, %{body: body}} = S3.get_bucket_object_versions(bucket) |> ExAws.request()

    versions =
      body
      |> xpath(~x"//Version[Key[contains(text(), \"#{String.trim_leading(key, "/")}\")]]"l,
        key: ~x"./Key/text()",
        version_id: ~x"./VersionId/text()",
        last_modified: ~x"./LastModified/text()"
      )
      |> Enum.map(fn version ->
        %Entry{
          key: key,
          data: nil,
          version: version.version_id,
          timestamp: version.last_modified
        }
      end)

    # return version ids or just number of versions?

    {:ok, versions}
  end

  @spec delete(%{bucket: binary()}, binary()) :: :ok
  def delete(%{bucket: bucket}, key) do
    S3.delete_object(bucket, key) |> ExAws.request()

    :ok
  end
end

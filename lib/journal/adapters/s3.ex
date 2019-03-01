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

  def init(config) do
    meta = %{
      bucket: config[:bucket]
    }

    {:ok, nil, meta}
  end

  def put(%{bucket: bucket}, key, value) do
    response = S3.put_object(bucket, key, value) |> ExAws.request()

    case response do
      {:ok, %{body: _}} ->
        {:ok, key}

      error ->
        error
    end
  end

  def get(%{bucket: bucket}, key) do
    response = S3.get_object(bucket, key) |> ExAws.request()

    case response do
      {:ok, %{body: body}} ->
        {:ok, body}

      {:error, {:http_error, 404, _}} ->
        {:ok, nil}
    end
  end

  def get(%{bucket: bucket}, key, version) do
    {:ok, key}
  end

  def version_count(%{bucket: bucket}, key) do
    0
  end

  def delete(%{bucket: bucket}, key) do
    S3.delete_object(bucket, key) |> ExAws.request()

    :ok
  end
end

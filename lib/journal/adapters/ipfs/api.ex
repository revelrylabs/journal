defmodule Journal.Adapters.IPFS.API do
  def cat(url, hash) do
    query =
      URI.encode_query(%{
        arg: hash
      })

    url = "#{url}/cat?#{query}"

    url
    |> HTTPoison.get()
    |> process_result()
  end

  def file_stat(url, path) do
    query =
      URI.encode_query(%{
        arg: path
      })

    url = "#{url}/files/stat?#{query}"

    url
    |> HTTPoison.get()
    |> process_result()
  end

  def file_write(url, path, data) do
    query =
      URI.encode_query(%{
        arg: path,
        truncate: true,
        create: true,
        parents: true
      })

    url = "#{url}/files/write?#{query}"
    filename = Path.basename(path)

    form =
      {:multipart,
       [
         {"file", data, {"form-data", [{"name", "file"}, {"filename", filename}]},
          [{"Content-Type", "application/octet-stream"}]}
       ]}

    url
    |> HTTPoison.post(form)
    |> process_result()
  end

  def file_read(url, path) do
    query =
      URI.encode_query(%{
        arg: path
      })

    url = "#{url}/files/read?#{query}"

    url
    |> HTTPoison.get()
    |> process_result()
  end

  def file_delete(url, path) do
    query =
      URI.encode_query(%{
        arg: path
      })

    url = "#{url}/files/rm?#{query}"

    url
    |> HTTPoison.delete()
    |> process_result()
  end

  def dag_put(url, dag) do
    query =
      URI.encode_query(%{
        pin: true
      })

    url = "#{url}/dag/put?#{query}"
    file = Jason.encode!(dag)

    form =
      {:multipart,
       [
         {"file", file, {"form-data", [{"name", "file"}, {"filename", "file.json"}]},
          [{"Content-Type", "application/json"}]}
       ]}

    url
    |> HTTPoison.post(form)
    |> process_result()
  end

  def dag_get(url, object) do
    query =
      URI.encode_query(%{
        arg: object
      })

    url = "#{url}/dag/get?#{query}"

    url
    |> HTTPoison.get()
    |> process_result()
  end

  defp process_result(result) do
    case result do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        maybe_parse_json({:ok, body})

      {:ok, %HTTPoison.Response{status_code: _, body: body}} ->
        maybe_parse_json({:error, body})

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "#{inspect(reason)}"}
    end
  end

  defp maybe_parse_json({status, body}) do
    case Jason.decode(body) do
      {:ok, map} ->
        {status, map}

      _ ->
        {status, body}
    end
  end
end

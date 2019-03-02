defmodule Journal.Adapter do
  @moduledoc """
  Specifies API for Journal adapters
  """

  @type adapter_meta :: map
  alias Journal.Entry
  alias Journal.Error

  @doc """
  Initializes the adapter
  """
  @callback init(config :: Keyword.t()) :: {:ok, :supervisor.child_spec() | nil, adapter_meta}

  @doc """
  Stores data by key. If there is data already associated with that key then the
  new data is stored as a new version.
  """
  @callback put(adapter_meta :: adapter_meta, key :: binary(), value :: any()) ::
              {:ok, Entry.t()} | {:error, Error.t()}

  @doc """
  Gets the latest version of data with the associated key or nil
  """
  @callback get(adapter_meta :: adapter_meta, key :: binary()) ::
              {:ok, Entry.t()} | {:error, Error.t()}

  @doc """
  Gets the specified version of data with the associated key or nil
  """
  @callback get(adapter_meta :: adapter_meta, key :: binary(), version :: integer) ::
              {:ok, Entry.t()} | {:error, Error.t()}

  @doc """
  Returns version data for the given key
  """
  @callback versions(adapter_meta :: adapter_meta, key :: binary()) ::
              {:ok, [Entry.t()]} | {:error, Error.t()}

  @doc """
  Removes all data associated with the key
  """
  @callback delete(adapter_meta :: adapter_meta, key :: binary()) :: :ok | {:error, Error.t()}
end

defmodule Journal.Adapter do
  @moduledoc """
  Specifies API for Journal adapters
  """

  @type adapter_meta :: map

  @doc """
  Initializes the adapter
  """
  @callback init(config :: Keyword.t()) :: {:ok, :supervisor.child_spec() | nil, adapter_meta}

  @doc """
  Stores data by key. If there is data already associated with that key then the
  new data is stored as a new version.
  """
  @callback put(adapter_meta :: adapter_meta, key :: binary(), value :: any()) ::
              {:ok, any()} | {:error, any()}

  @doc """
  Gets the latest version of data with the associated key or nil
  """
  @callback get(adapter_meta :: adapter_meta, key :: binary()) :: any() | nil

  @doc """
  Gets the specified version of data with the associated key or nil
  """
  @callback get(adapter_meta :: adapter_meta, key :: binary(), version :: integer) :: any() | nil

  @doc """
  Returns the number of versions for the associated key
  """
  @callback version_count(adapter_meta :: adapter_meta, key :: binary()) :: integer()

  @doc """
  Removes all data associated with the key
  """
  @callback delete(adapter_meta :: adapter_meta, key :: binary()) :: :ok
end

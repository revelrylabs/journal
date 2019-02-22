defmodule Journal.Adapter do
  @callback put(key :: binary(), value :: any()) :: {:ok, any()} | {:error, any()}

  @callback get(key :: binary()) :: any() | nil

  @callback get(key :: binary(), version :: integer) :: any() | nil

  @callback versions(key :: binary()) :: integer()

  @callback delete(key :: binary()) :: :ok
end

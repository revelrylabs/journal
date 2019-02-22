defmodule Journal.Adapters.Memory do
  @behaviour Journal.Adapter

  def put(key, _value) do
    {:ok, key}
  end

  def get(_key) do
    ""
  end

  def get(_key, _version) do
    ""
  end

  def versions(_key) do
    0
  end

  def delete(_key) do
    :ok
  end
end

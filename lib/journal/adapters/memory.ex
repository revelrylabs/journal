defmodule Journal.Adapters.Memory do
  @behaviour Journal.Adapter
  @moduledoc """
  In-memory adapter for Journal. Stores data and versions inside an
  Agent.
  """
  alias Journal.{Entry, Error}

  def init(_config) do
    meta = %{}

    child_spec = %{
      id: Journal.Adapters.Memory.Agent,
      start: {Journal.Adapters.Memory.Agent, :start_link, []}
    }

    {:ok, child_spec, meta}
  end

  def put(%{pid: agent}, key, value) do
    Journal.Adapters.Memory.Agent.put(agent, key, value)
    get(%{pid: agent}, key)
  end

  def get(%{pid: agent}, key) do
    case Journal.Adapters.Memory.Agent.get(agent, key) do
      %Entry{} = data ->
        {:ok, data}

      %Error{} = error ->
        {:error, error}
    end
  end

  def get(%{pid: agent}, key, version) do
    case Journal.Adapters.Memory.Agent.get(agent, key, version) do
      %Entry{} = data ->
        {:ok, data}

      %Error{} = error ->
        {:error, error}
    end
  end

  def versions(%{pid: agent}, key) do
    case Journal.Adapters.Memory.Agent.versions(agent, key) do
      entries when is_list(entries) ->
        {:ok, entries}

      %Error{} = error ->
        {:error, error}
    end
  end

  def delete(%{pid: agent}, key) do
    Journal.Adapters.Memory.Agent.delete(agent, key)

    :ok
  end
end

defmodule Journal.Adapters.Memory do
  @behaviour Journal.Adapter
  @moduledoc """
  In-memory adapter for Journal. Stores data and versions inside an
  Agent.
  """

  def init(_config) do
    meta = %{}

    child_spec = %{
      id: Journal.Adapters.Memory.Agent,
      start: {Journal.Adapters.Memory.Agent, :start_link, []}
    }

    {:ok, child_spec, meta}
  end

  def put(%{pid: agent}, key, value) do
    :ok = Journal.Adapters.Memory.Agent.put(agent, key, value)
    {:ok, key}
  end

  def get(%{pid: agent}, key) do
    value = Journal.Adapters.Memory.Agent.get(agent, key)
    {:ok, value}
  end

  def get(%{pid: agent}, key, version) do
    value = Journal.Adapters.Memory.Agent.get(agent, key, version)
    {:ok, value}
  end

  def version_count(%{pid: agent}, key) do
    Journal.Adapters.Memory.Agent.version_count(agent, key)
  end

  def delete(%{pid: agent}, key) do
    Journal.Adapters.Memory.Agent.delete(agent, key)

    :ok
  end
end

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

defmodule Journal.Adapters.Memory.Agent do
  @moduledoc false
  use Agent

  def start_link() do
    data = %{}

    Agent.start_link(fn -> data end)
  end

  def put(pid, key, value) do
    Agent.update(pid, fn state ->
      if Map.has_key?(state, key) do
        Map.put(state, key, [value | state[key]])
      else
        Map.put(state, key, [value])
      end
    end)
  end

  def get(pid, key) do
    Agent.get(pid, fn state ->
      if Map.has_key?(state, key) do
        hd(state[key])
      else
        nil
      end
    end)
  end

  def get(pid, key, version) do
    Agent.get(pid, fn state ->
      if Map.has_key?(state, key) do
        state[key]
        |> Enum.reverse()
        |> Enum.at(version)
      else
        nil
      end
    end)
  end

  def version_count(pid, key) do
    Agent.get(pid, fn state ->
      if Map.has_key?(state, key) do
        length(state[key])
      else
        0
      end
    end)
  end

  def delete(pid, key) do
    Agent.update(pid, fn state ->
      if Map.has_key?(state, key) do
        Map.drop(state, [key])
      else
        state
      end
    end)
  end
end

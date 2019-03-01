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

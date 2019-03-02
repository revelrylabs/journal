defmodule Journal.Adapters.Memory.Agent do
  @moduledoc false
  use Agent
  alias Journal.{Entry, Error}

  def start_link() do
    data = %{}

    Agent.start_link(fn -> data end)
  end

  def put(pid, key, value) do
    Agent.update(pid, fn state ->
      if Map.has_key?(state, key) do
        entry = %Entry{
          key: key,
          data: value,
          version: length(state[key]),
          timestamp: DateTime.utc_now() |> DateTime.to_iso8601()
        }

        Map.put(state, key, [entry | state[key]])
      else
        entry = %Entry{
          key: key,
          data: value,
          version: 0,
          timestamp: DateTime.utc_now() |> DateTime.to_iso8601()
        }

        Map.put(state, key, [entry])
      end
    end)
  end

  def get(pid, key) do
    Agent.get(pid, fn state ->
      if Map.has_key?(state, key) do
        hd(state[key])
      else
        %Error{
          key: key,
          error: "key not found"
        }
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
        %Error{
          key: key,
          error: "key not found"
        }
      end
    end)
  end

  def versions(pid, key) do
    Agent.get(pid, fn state ->
      if Map.has_key?(state, key) do
        state[key]
        |> Enum.reverse()
      else
        %Error{
          key: key,
          error: "key not found"
        }
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

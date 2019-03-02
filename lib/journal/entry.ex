defmodule Journal.Entry do
  @type t :: %__MODULE__{}
  defstruct [:key, :data, :version, :timestamp]
end

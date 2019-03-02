defmodule Journal.Error do
  @type t :: %__MODULE__{}
  defstruct [:key, :error]
end

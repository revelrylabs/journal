defmodule Journal.Memory do
  use Journal, otp_app: :journal, adapter: Journal.Adapters.Memory
end

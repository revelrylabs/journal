defmodule Journal.IPFS do
  use Journal, otp_app: :journal, adapter: Journal.Adapters.IPFS
end

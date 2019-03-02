defmodule Journal.S3 do
  use Journal, otp_app: :journal, adapter: Journal.Adapters.S3
end

# Journal

Versioned key/value store with multiple backend support

## Usage

```elixir
# In your config/config.exs file
config :my_app, MyApp.Journal

# In your application code
defmodule MyApp.Journal do
  use Journal,
    otp_app: :my_app,
    adapter: Journal.Adapters.Memory
end

# Start
{:ok, _} = MyApp.Journal.start_link()

# Alternatively, add to your application's supervision tree

supervisor(MyApp.Journal, [])

# Use
MyApp.Journal.put("hello", "there")
# {:ok, "hello"}

MyApp.Journal.get("hello")
# {:ok, "there"}
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `journal` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:journal, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/journal](https://hexdocs.pm/journal).

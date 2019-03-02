defmodule Journal do
  @moduledoc """
  Versioned key/value store with multiple backend support
  """

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      @otp_app opts[:otp_app]
      @adapter opts[:adapter]

      def child_spec(opts) do
        %{
          id: __MODULE__,
          start: {__MODULE__, :start_link, [opts]},
          type: :supervisor
        }
      end

      def start_link(opts \\ []) do
        Journal.Supervisor.start_link(__MODULE__, @otp_app, @adapter, opts)
      end

      def stop(timeout \\ 5000) do
        Supervisor.stop(__MODULE__, :normal, timeout)
      end

      def put(key, value) do
        @adapter.put(meta(), key, value)
      end

      def get(key) do
        @adapter.get(meta(), key)
      end

      def get(key, version) do
        @adapter.get(meta(), key, version)
      end

      def versions(key) do
        @adapter.versions(meta(), key)
      end

      def delete(key) do
        @adapter.delete(meta(), key)
      end

      defp meta() do
        [{_, {_adapter, meta}}] = Registry.lookup(Journal.Registry, __MODULE__)
        meta
      end
    end
  end
end

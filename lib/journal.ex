defmodule Journal do
  @moduledoc """
  Documentation for Journal.
  """

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      @otp_app opts[:otp_app]
      @adapter opts[:adapter]

      def put(key, value) do
        @adapter.put(key, value)
      end

      def get(key) do
        @adapter.get(key)
      end

      def get(key, version) do
        @adapter.get(key, version)
      end

      def versions(key) do
        @adapter.versions(key)
      end

      def delete(key) do
        @adapter.delete(key)
      end
    end
  end
end

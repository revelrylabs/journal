defmodule Journal.Supervisor do
  use Supervisor
  @moduledoc false

  def start_link(journal, otp_app, adapter, opts) do
    sup_opts = if name = Keyword.get(opts, :name, journal), do: [name: name], else: []
    Supervisor.start_link(__MODULE__, {name, journal, otp_app, adapter, opts}, sup_opts)
  end

  @impl true
  def init({_name, journal, otp_app, adapter, opts}) do
    # Get configuration. To be passed to adapter
    config = Application.get_env(otp_app, journal, [])
    opts = [otp_app: otp_app] ++ Keyword.merge(opts, config)

    # init the adapter and get the child spec and meta data
    {:ok, child_spec, meta} = adapter.init([journal: journal] ++ opts)

    children =
      case child_spec do
        nil ->
          Registry.register(Journal.Registry, journal, {adapter, meta})
          []

        _ ->
          child_spec = wrap_child_spec(child_spec, [adapter, journal, meta])
          [child_spec]
      end

    Supervisor.init(children, strategy: :one_for_one, max_restarts: 0)
  end

  @doc """
  Used to start the adapter. Wraped in this function so that
  the supervisor can track the pid of the started process.
  This is kept and given to the adapters.
  """
  def start_child({mod, fun, args}, adapter, journal, meta) do
    case apply(mod, fun, args) do
      {:ok, pid} ->
        meta = Map.merge(meta, %{pid: pid})
        Registry.register(Journal.Registry, journal, {adapter, meta})

        {:ok, pid}

      other ->
        other
    end
  end

  defp wrap_child_spec({id, start, restart, shutdown, type, mods}, args) do
    {id, {__MODULE__, :start_child, [start | args]}, restart, shutdown, type, mods}
  end

  defp wrap_child_spec(%{start: start} = spec, args) do
    %{spec | start: {__MODULE__, :start_child, [start | args]}}
  end
end

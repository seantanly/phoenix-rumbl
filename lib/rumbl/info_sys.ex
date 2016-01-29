defmodule Rumbl.InfoSys do
  require Logger
  @backends [Rumbl.InfoSys.Wolfram]

  defmodule Result do
    @doc """
    The score for storing relevance, text to describe the result, the url it came from, and the backend (user) used for the computation.
    """
    defstruct score: 0, text: nil, url: nil, backend: nil
  end

  def compute(query, opts \\ []) do
    limit = opts[:limit] || 10

    @backends
    |> Enum.map(fn backend ->
      spawn_query(backend, query, limit)
    end)
    |> await_results(opts)
    |> Enum.sort(&(&1.score >= &2.score))
    |> Enum.take(limit)
  end

  defp await_results(query_children, opts) do
    timeout = opts[:timeout] || 5000
    timer = Process.send_after(self(), :timeout, timeout)
    results = do_await_results(query_children, [], :infinity)
    cleanup_timer(timer)
    results
    |> Enum.reverse
  end
  defp do_await_results([], acc, _timeout), do: acc
  defp do_await_results([{query_pid, monitor_ref}|query_children], acc, timeout) do
    receive do
      {:result, ^query_pid, result} ->
        Process.demonitor(monitor_ref, [:flush])
        new_acc = if result, do: [result|acc], else: acc
        do_await_results(query_children, new_acc, timeout)
      {:DOWN, ^monitor_ref, :process, ^query_pid, _reason}=down_info ->
        Logger.debug "DOWN: #{inspect down_info}"
        Process.demonitor(monitor_ref, [:flush])
        do_await_results(query_children, acc, timeout)
      :timeout ->
        Logger.debug "Timeout: #{inspect query_pid}"
        kill(query_pid, monitor_ref)
        do_await_results(query_children, acc, 0)
    after
      timeout ->
        kill(query_pid, monitor_ref)
        do_await_results(query_children, acc, 0)
    end
  end

  defp kill(query_pid, monitor_ref) do
    Process.demonitor(monitor_ref, [:flush])
    Process.exit(query_pid, :kill)
  end

  defp cleanup_timer(timer) do
    :erlang.cancel_timer(timer)
    receive do
      :timeout -> :ok
    after
      0 -> :ok
    end
  end

  def spawn_query(backend, query, limit) do
    opts = [backend, query, limit, self()]
    {:ok, pid} = Supervisor.start_child(Rumbl.InfoSys.Supervisor, opts)
    monitor_ref = Process.monitor(pid)
    {pid, monitor_ref} # pid doubling up as unqiue query ref
  end

  def start_link(backend, query, limit, owner) do
    backend.start_link(query, limit, owner)
  end

end

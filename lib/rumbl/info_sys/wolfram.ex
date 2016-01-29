defmodule Rumbl.InfoSys.Wolfram do
  @moduledoc """
  Interface module to query [WolframAplha](http://www.wolframalpha.com)
  """
  import SweetXml
  alias Rumbl.InfoSys.Result

  defp app_id(), do: Application.get_env(:rumbl, :wolfram)[:app_id]
  defp user(), do: Rumbl.Repo.get_by(Rumbl.User, username: "wolfram")

  def start_link(query, limit, owner) do
    Task.start_link(__MODULE__, :fetch, [query, owner, limit])
  end

  def fetch(query_str, owner, _limit) do
    query_str
    |> fetch_xml
    |> parse_xml
    |> send_results(owner)
  end

  def fetch_xml(query_str) do
    query_url =
      "http://api.wolframalpha.com/v2/query" <>
      "?appid=#{app_id()}" <>
      "&input=#{URI.encode(query_str)}" <>
      "&format=plaintext"
      |> IO.inspect
    {:ok, {_, _, body}} = :httpc.request(
      query_url |> String.to_char_list
    )
    body
  end

  def parse_xml(xml) do
    xml
    |> xpath(
        ~x"//queryresult/pod[@primary='true']/subpod/plaintext/text()"s
      )
  end

  def send_results(answer, owner) do
    case String.strip(answer) do
      "" -> send(owner, {:result, self(), nil})
      _ ->
        results = %Result{backend: user(), score: 95, text: answer}
        send(owner, {:result, self(), results})
    end
  end

end

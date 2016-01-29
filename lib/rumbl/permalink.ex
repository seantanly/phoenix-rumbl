defmodule Rumbl.Permalink do
  @behaviour Ecto.Type

  def type, do: :id

  def cast(str) when is_bitstring(str) do
    case Integer.parse(str) do
      {int, _} when int > 0 -> {:ok, int}
      _ -> :error
    end
  end
  def cast(int) when is_integer(int), do: {:ok, int}
  def cast(_), do: :error

  def dump(int) when is_integer(int), do: {:ok, int}
  def dump(_), do: :error

  def load(int) when is_integer(int), do: {:ok, int}
  def load(_), do: :error
end

defmodule Rumbl.VideoView do
  use Rumbl.Web, :view

  def mattr(map, key), do: mattr(map, key, nil)
  def mattr(nil, _, default), do: default
  def mattr(%{}=map, key, default), do: map |> Map.get(key, default)
end

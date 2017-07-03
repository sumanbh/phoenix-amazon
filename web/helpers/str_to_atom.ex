defmodule Amazon.StringToAtom do

  def convert(object) do
    for {key, val} <- object, into: %{}, do: {String.to_atom(key), val}
  end

end

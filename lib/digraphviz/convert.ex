defmodule Digraphviz.Convert do

  def convert(digraph, type \\ :digraph, attributes \\ []) do

    type = case type do
             :digraph -> "digraph"
             _ -> "graph"
           end

    [
      type, " {",
      "graph ", "[", attributes(attributes), "]",
      "}"
    ]
  end

  defp attributes([]), do: []
  defp attributes(attrs_list) do
    attrs_list |> Enum.map(&attr/1)
  end

  defp attr(attribute) when is_binary(attribute), do: attribute
  defp attr({name, val}) do
    "#{name}=#{val},"
  end

end

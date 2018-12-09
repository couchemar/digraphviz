defmodule Digraphviz.Types.AList do
  @moduledoc false

  def convert(attr_list) do
    List.foldr(attr_list, [], fn
      {_k, _w} = kw, [] = acc -> [attr(kw) | acc]
      {_k, _w} = kw, acc -> [[attr(kw), ", "] | acc]
      _, acc -> acc
    end)
  end

  defp attr({name, val}) do
    val = handle_str(val)
    "#{name}=#{val}"
  end

  defp handle_str(val) when is_binary(val) do
    "\"#{val}\""
  end

  defp handle_str(val), do: val
end

defmodule Digraphviz.Types.AttrsList do
  @moduledoc false

  alias Digraphviz.Types.AList

  def convert(attr_list) do
    case AList.convert(attr_list) do
      [] -> []
      attr_list -> [" [", attr_list, "];"]
    end
  end
end

defmodule Digraphviz.Types.Attributes do
  @moduledoc false

  alias Digraphviz.Types.AList
  alias Digraphviz.Types.AttrsList

  def convert(attributes) do
    {graph_attrs, attributes} = Keyword.pop(attributes, :graph)
    {node_attrs, attributes} = Keyword.pop(attributes, :node)
    {edge_attrs, attributes} = Keyword.pop(attributes, :edge)

    [
      unless graph_attrs == nil do
        ["graph", AttrsList.convert(graph_attrs)]
      else
        []
      end,
      unless node_attrs == nil do
        ["node", AttrsList.convert(node_attrs)]
      else
        []
      end,
      unless edge_attrs == nil do
        ["edge", AttrsList.convert(edge_attrs)]
      else
        []
      end,
      case AList.convert(attributes) do
        [] -> []
        attrs -> [attrs, ";"]
      end
    ]
  end
end

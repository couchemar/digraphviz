defmodule Digraphviz.Converter do
  defmodule Digraphviz.Converter.Graph do
    defstruct ~w(
      digraph
      type
      subgraphs
      node_converter
    )a
  end

  alias Digraphviz.Converter.Graph

  def from(digraph) do
    %Graph{digraph: digraph}
  end

  def convert(graph, type \\ :digraph, attributes \\ []) do
    type =
      case type do
        :digraph -> "digraph"
        :graph -> "graph"
      end

    [
      type,
      " {",
      graph_attributes(attributes),
      nodes(graph),
      "}"
    ]
  end

  defp graph_attributes(attributes) do
    graph_attrs = Keyword.get(attributes, :graph, [])
    node_attrs = Keyword.get(attributes, :node, [])
    edge_attrs = Keyword.get(attributes, :edge, [])

    [
      if not Enum.empty?(graph_attrs) do
        ["graph", graph_attrs]
      else
        []
      end,
      if not Enum.empty?(node_attrs) do
        ["node", node_attrs]
      else
        []
      end,
      if not Enum.empty?(edge_attrs) do
        ["edge", edge_attrs]
      else
        []
      end
    ]
  end

  defp nodes(graph) do
    node_list = :digraph.vertices(graph.digraph)

    converter =
      case graph.node_converter do
        nil -> &node/2
        conv -> conv
      end

    node_list |> Enum.map(process_node(graph.digraph, converter))
  end

  defp process_node(digraph, fun) do
    fn node_name ->
      case :digraph.vertex(digraph, node_name) do
        false -> []
        {node_name, label} -> [fun.(node_name, label)]
      end
    end
  end

  defp node(name, label) do
    [node_name(name), attributes(label)]
  end

  defp node_name(name) when is_binary(name) do
    "#{inspect(name)}"
  end

  defp node_name(name) do
    escaped = "#{inspect(name)}" |> String.replace("\"", "\\\"")
    "\"#{escaped}\""
  end

  defp attributes(attrs) when is_list(attrs) do
    case List.foldr(attrs, [], fn
           {_k, _w} = kw, acc -> [attr(kw) | acc]
           _, acc -> acc
         end) do
      [] -> []
      attr_list -> [" [", attr_list, "];"]
    end
  end

  defp attr({name, val}) do
    "#{name}=#{val},"
  end
end

defmodule Digraphviz.Converter do
  @moduledoc false
  defmodule Document do
    @moduledoc false
    defstruct ~w(
      digraph
      subgraphs
      node_converter
      edge_converter
    )a
  end

  alias Digraphviz.Types

  def from(digraph) do
    %Document{digraph: digraph}
  end

  def convert(graph, type \\ :digraph, attributes \\ []) do
    stype =
      case type do
        :digraph -> "digraph"
        :graph -> "graph"
      end

    nodes_and_subgraphs = process(graph)

    [
      stype,
      " {",
      graph_attributes(attributes),
      subgraphs(nodes_and_subgraphs.subgraphs),
      nodes_and_subgraphs.nodes,
      edges(graph, type),
      "}"
    ]
  end

  defp process(graph) do
    converter =
      case graph.node_converter do
        nil -> &node/2
        conv -> conv
      end

    :digraph.vertices(graph.digraph)
    |> Stream.map(fn n ->
      {^n, _l} = :digraph.vertex(graph.digraph, n)
    end)
    |> Enum.reduce(
      Types.Subgraph.create(),
      fn {v, l}, g ->
        case converter.(v, l) do
          {n, nil} -> Types.Subgraph.add_node(g, n)
          {n, subgraph} -> Types.Subgraph.add_node_to_subgraph(g, n, subgraph)
        end
      end
    )
  end

  defp graph_attributes(attributes) do
    graph_attrs = Keyword.get(attributes, :graph, [])
    node_attrs = Keyword.get(attributes, :node, [])
    edge_attrs = Keyword.get(attributes, :edge, [])

    [
      unless Enum.empty?(graph_attrs) do
        ["graph", graph_attrs]
      else
        []
      end,
      unless Enum.empty?(node_attrs) do
        ["node", node_attrs]
      else
        []
      end,
      unless Enum.empty?(edge_attrs) do
        ["edge", edge_attrs]
      else
        []
      end
    ]
  end

  defp subgraphs(subgraphs) do
    Types.Subgraph.fold(subgraphs)
  end

  defp edges(graph, type) do
    edge_list = :digraph.edges(graph.digraph)

    converter =
      case graph.edge_converter do
        nil -> &edge/4
        conv -> conv
      end

    edge_list |> Enum.map(process_edge(graph.digraph, converter, type))
  end

  defp process_edge(digraph, fun, type) do
    fn edge_name ->
      case :digraph.edge(digraph, edge_name) do
        false -> []
        {^edge_name, v1, v2, label} -> fun.(v1, v2, label, type)
      end
    end
  end

  defp node(name, label) do
    {subgraph, label} = Keyword.pop(label, :subgraph)
    {[Types.ID.convert(name), attributes(label)], subgraph}
  end

  defp edge(v1, v2, label, type) do
    connect =
      case type do
        :digraph -> "->"
        :graph -> "--"
      end

    [Types.ID.convert(v1), connect, Types.ID.convert(v2), attributes(label)]
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

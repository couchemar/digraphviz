defmodule Digraphviz.Types.Subgraph do
  alias Digraphviz.Types.ID

  @moduledoc false
  defstruct [:nodes, :subgraphs]

  def create do
    %__MODULE__{nodes: [], subgraphs: %{}}
  end

  def add_node(graph, node) do
    Map.update(graph, :nodes, [], fn nodes -> [node | nodes] end)
  end

  def add_node_to_subgraph(graph, node, subgraph) when is_tuple(subgraph) do
    add_node_to_subgraph(graph, node, Tuple.to_list(subgraph))
  end

  def add_node_to_subgraph(graph, node, [subgraph | rest]) do
    Map.update(graph, :subgraphs, %{}, fn sg ->
      if Map.has_key?(sg, subgraph) do
        Map.update(sg, subgraph, create(), fn nested ->
          add_node_to_subgraph(nested, node, rest)
        end)
      else
        Map.put_new_lazy(sg, subgraph, fn -> add_node_to_subgraph(create(), node, rest) end)
      end
    end)
  end

  def add_node_to_subgraph(graph, node, []) do
    add_node(graph, node)
  end

  def add_node_to_subgraph(graph, node, subgraph) do
    add_node_to_subgraph(graph, node, [subgraph])
  end

  def fold(graphs) do
    graphs
    |> Enum.reduce([], fn {name, val}, acc ->
      [["subgraph ", ID.convert(name), " {", fold(val.subgraphs), val.nodes, "}"] | acc]
    end)
  end
end

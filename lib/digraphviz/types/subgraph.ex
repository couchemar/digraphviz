defmodule Digraphviz.Types.Subgraph do
  alias Digraphviz.Types.ID
  alias Digraphviz.Types.Attributes

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

  def fold(graphs, subgraphs_info) do
    graphs
    |> Enum.reduce([], fn {name, val}, acc ->
      sg = Map.get(subgraphs_info, name, %{})

      attrs =
        case sg[:attributes] do
          nil -> []
          attrs -> Attributes.convert(attrs)
        end

      [
        [
          "subgraph ",
          ID.convert(name),
          " {",
          attrs,
          fold(val.subgraphs, sg),
          val.nodes,
          "}"
        ]
        | acc
      ]
    end)
  end
end

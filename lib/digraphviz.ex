defmodule Digraphviz do
  @moduledoc """
  Digraphviz -- converts Erlang :digraph to graph description in .dot language.
  """
  alias Digraphviz.Converter

  @doc """
  Converts :digraph to iodata which contains .dot.

  `attributes` defines global attributes for graph, nodes and edges.

  * :graph -- graph attributes
  * :node -- node attributes
  * edge -- edge attributes

  Attributes can hold any values, but only keywords will appear in resulting .dot.

  For example:

  ```
  Digraphviz.convert(graph, :digraph, graph: [fontsize: 10], node: [shape: :record], edge: [color: :red])
  ```

  The subgraph attributes can be placed in `subgraphs` map:

  ```
  %{
      "cluster_1": %{
          :attributes => [node: [...], edge: [...], grap: []],
          "cluster_1_2": %{
              ...
          }
      }
  }
  Subgraphs can be nested.
  ```
  """
  @spec convert(:digraph.new(), :digraph | :graph, Keyword.t(), Map.t()) :: iodata()
  def convert(digraph, type \\ :digraph, attributes \\ [], subgraphs \\ %{}) do
    Converter.from(digraph) |> Converter.convert(type, attributes, subgraphs)
  end
end

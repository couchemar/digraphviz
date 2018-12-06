defmodule Digraphviz do
  @moduledoc """
  Digraphviz -- converts Erlang :digraph to graph description in .dot language.
  """
  alias Digraphviz.Converter

  @doc """
  Converts :digraph to iodata which contains .dot.

  `attributes` define global attributes for graph, nodes and edges.

  * :graph -- graph attributes
  * :node -- node attributes
  * edge -- edge attributes

  Attributes can hold any values, but only keywords will appear in resulting .dot.

  For example:

  ```
  Digraphviz.convert(graph, :digraph, graph: [fontsize: 10], node: [shape: :record], edge: [color: :red])
  ```
  """
  @spec convert(:digraph.new(), :digraph | :graph, Keyword.t()) :: iodata()
  def convert(digraph, type \\ :digraph, attributes \\ []) do
    Converter.from(digraph) |> Converter.convert(type, attributes)
  end
end

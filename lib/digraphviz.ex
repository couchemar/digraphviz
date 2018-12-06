defmodule Digraphviz do
  @moduledoc """
  Digraphviz -- converts digraph to .dot.
  """

  @doc """
  """

  def convert(digraph, type \\ :digraph, attributes \\ []) do
    Digraphviz.Converter.convert(digraph, type, attributes)
  end
end

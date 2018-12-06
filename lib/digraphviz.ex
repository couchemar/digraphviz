defmodule Digraphviz do
  @moduledoc """
  Digraphviz -- converts Erlang :digraph to .dot.
  """

  @doc """
  """

  alias Digraphviz.Converter

  def convert(digraph, type \\ :digraph, attributes \\ []) do
    Converter.from(digraph) |> Converter.convert(type, attributes)
  end
end

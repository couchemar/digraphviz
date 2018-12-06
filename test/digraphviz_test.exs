defmodule DigraphvizTest do
  use ExUnit.Case
  doctest Digraphviz

  setup _ do
    digraph = :digraph.new()
    [digraph: digraph]
  end

  describe "Empty graph's convert" do
    test "default arguments", ctx do
      assert Digraphviz.convert(ctx.digraph) == ["digraph", " {", "graph ", "[", [], "]", "}"]
    end

    test "with type", ctx do
      assert Digraphviz.convert(ctx.digraph, :graph) == [
               "graph",
               " {",
               "graph ",
               "[",
               [],
               "]",
               "}"
             ]
    end

    test "with attributes", ctx do
      assert Digraphviz.convert(ctx.digraph, :graph, [
               "foo=bar",
               "fiz=buz",
               {:a, :b},
               {"55", 42.2}
             ]) == [
               "graph",
               " {",
               "graph ",
               "[",
               ["foo=bar,", "fiz=buz,", "a=b,", "55=42.2,"],
               "]",
               "}"
             ]
    end
  end
end

defmodule DigraphvizTest do
  use ExUnit.Case
  doctest Digraphviz

  setup _ do
    digraph = :digraph.new()
    [digraph: digraph]
  end

  describe "Empty graph's convert" do
    test "default arguments", ctx do
      assert Digraphviz.convert(ctx.digraph) == [
               "digraph",
               " {",
               [[], [], []],
               [],
               [],
               "}"
             ]
    end

    test "with type", ctx do
      assert Digraphviz.convert(ctx.digraph, :graph) == [
               "graph",
               " {",
               [[], [], []],
               [],
               [],
               "}"
             ]
    end

    test "with attributes: graph", ctx do
      assert Digraphviz.convert(ctx.digraph, :graph,
               graph: [
                 {:a, :b},
                 {"55", 42.2}
               ]
             ) == ["graph", " {", [["graph", [{:a, :b}, {"55", 42.2}]], [], []], [], [], "}"]
    end

    test "with attributes: node", ctx do
      assert Digraphviz.convert(ctx.digraph, :graph,
               node: [
                 {:a, :b},
                 {"55", 42.2}
               ]
             ) == ["graph", " {", [[], ["node", [{:a, :b}, {"55", 42.2}]], []], [], [], "}"]
    end

    test "with attributes: edge", ctx do
      assert Digraphviz.convert(ctx.digraph, :graph,
               edge: [
                 {:a, :b},
                 {"55", 42.2}
               ]
             ) == ["graph", " {", [[], [], ["edge", [{:a, :b}, {"55", 42.2}]]], [], [], "}"]
    end
  end

  test "Graph with anonymous nodes", ctx do
    :digraph.add_vertex(ctx.digraph)
    :digraph.add_vertex(ctx.digraph)
    :digraph.add_vertex(ctx.digraph)

    assert Digraphviz.convert(ctx.digraph) == [
             "digraph",
             " {",
             [[], [], []],
             [
               ["\"[:\\\"$v\\\" | 2]\"", []],
               ["\"[:\\\"$v\\\" | 1]\"", []],
               ["\"[:\\\"$v\\\" | 0]\"", []]
             ],
             [],
             "}"
           ]
  end

  test "Graph nodes with names and attributes", ctx do
    :digraph.add_vertex(ctx.digraph, :foo, [:fiz, {:buz, :bar}])
    :digraph.add_vertex(ctx.digraph, "bar", color: "green")
    :digraph.add_vertex(ctx.digraph, 42, color: "red", border: 4)

    assert Digraphviz.convert(ctx.digraph) == [
             "digraph",
             " {",
             [[], [], []],
             [
               ["\":foo\"", [" [", ["buz=bar,"], "];"]],
               ["\"42\"", [" [", ["color=red,", "border=4,"], "];"]],
               ["\"bar\"", [" [", ["color=green,"], "];"]]
             ],
             [],
             "}"
           ]
  end

  describe "Nodes and edges" do
    setup ctx do
      v1 = :digraph.add_vertex(ctx.digraph)
      v2 = :digraph.add_vertex(ctx.digraph)

      [v1: v1, v2: v2]
    end

    test "without attributes", ctx do
      :digraph.add_edge(ctx.digraph, ctx.v1, ctx.v2)
      :digraph.add_edge(ctx.digraph, ctx.v2, ctx.v1)

      assert Digraphviz.convert(ctx.digraph) == [
               "digraph",
               " {",
               [[], [], []],
               [["\"[:\\\"$v\\\" | 1]\"", []], ["\"[:\\\"$v\\\" | 0]\"", []]],
               [
                 ["\"[:\\\"$v\\\" | 1]\"", "->", "\"[:\\\"$v\\\" | 0]\"", []],
                 ["\"[:\\\"$v\\\" | 0]\"", "->", "\"[:\\\"$v\\\" | 1]\"", []]
               ],
               "}"
             ]
    end

    test "with attributes", ctx do
      :digraph.add_edge(ctx.digraph, ctx.v1, ctx.v2, foo: :bar)
      :digraph.add_edge(ctx.digraph, ctx.v2, ctx.v1, fiz: "buz")

      assert Digraphviz.convert(ctx.digraph) == [
               "digraph",
               " {",
               [[], [], []],
               [["\"[:\\\"$v\\\" | 1]\"", []], ["\"[:\\\"$v\\\" | 0]\"", []]],
               [
                 [
                   "\"[:\\\"$v\\\" | 1]\"",
                   "->",
                   "\"[:\\\"$v\\\" | 0]\"",
                   [" [", ["fiz=buz,"], "];"]
                 ],
                 [
                   "\"[:\\\"$v\\\" | 0]\"",
                   "->",
                   "\"[:\\\"$v\\\" | 1]\"",
                   [" [", ["foo=bar,"], "];"]
                 ]
               ],
               "}"
             ]
    end
  end
end

defmodule DigraphvizTest do
  use ExUnit.Case
  doctest Digraphviz

  def sort_by_first([a | _], [b | _]) do
    a < b
  end

  setup _ do
    digraph = :digraph.new()
    [digraph: digraph]
  end

  describe "Empty graph's convert" do
    test "default arguments", ctx do
      assert Digraphviz.convert(ctx.digraph) == [
               "digraph",
               " {",
               [[], [], [], []],
               [],
               [],
               [],
               "}"
             ]
    end

    test "with type", ctx do
      assert Digraphviz.convert(ctx.digraph, :graph) == [
               "graph",
               " {",
               [[], [], [], []],
               [],
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
             ) == [
               "graph",
               " {",
               [["graph", [" [", [["a=b", ", "], "55=42.2"], "];"]], [], [], []],
               [],
               [],
               [],
               "}"
             ]
    end

    test "with attributes: node", ctx do
      assert Digraphviz.convert(ctx.digraph, :graph,
               node: [
                 {:a, :b},
                 {"55", 42.2}
               ]
             ) == [
               "graph",
               " {",
               [[], ["node", [" [", [["a=b", ", "], "55=42.2"], "];"]], [], []],
               [],
               [],
               [],
               "}"
             ]
    end

    test "with attributes: edge", ctx do
      assert Digraphviz.convert(ctx.digraph, :graph,
               edge: [
                 {:a, :b},
                 {"55", 42.2}
               ]
             ) == [
               "graph",
               " {",
               [[], [], ["edge", [" [", [["a=b", ", "], "55=42.2"], "];"]], []],
               [],
               [],
               [],
               "}"
             ]
    end
  end

  test "Graph with anonymous nodes", ctx do
    :digraph.add_vertex(ctx.digraph)
    :digraph.add_vertex(ctx.digraph)
    :digraph.add_vertex(ctx.digraph)

    assert Digraphviz.convert(ctx.digraph) == [
             "digraph",
             " {",
             [[], [], [], []],
             [],
             [
               ["\"[:\\\"$v\\\" | 1]\"", []],
               ["\"[:\\\"$v\\\" | 0]\"", []],
               ["\"[:\\\"$v\\\" | 2]\"", []]
             ],
             [],
             "}"
           ]
  end

  test "Graph nodes with names and attributes", ctx do
    :digraph.add_vertex(ctx.digraph, :foo, [:fiz, {:buz, :bar}])
    :digraph.add_vertex(ctx.digraph, "bar", color: "green")
    :digraph.add_vertex(ctx.digraph, 42, color: "red", border: 4)

    [
      "digraph",
      " {",
      [[], [], [], []],
      [],
      nodes,
      [],
      "}"
    ] = Digraphviz.convert(ctx.digraph)

    assert Enum.sort(nodes, &sort_by_first/2) == [
             ["\"42\"", [" [", [["color=\"red\"", ", "], "border=4"], "];"]],
             ["\":foo\"", [" [", ["buz=bar"], "];"]],
             ["\"bar\"", [" [", ["color=\"green\""], "];"]]
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

      [
        "digraph",
        " {",
        [[], [], [], []],
        [],
        nodes,
        edges,
        "}"
      ] = Digraphviz.convert(ctx.digraph)

      assert Enum.sort(nodes, &sort_by_first/2) == [
               ["\"[:\\\"$v\\\" | 0]\"", []],
               ["\"[:\\\"$v\\\" | 1]\"", []]
             ]

      assert Enum.sort(edges, &sort_by_first/2) == [
               ["\"[:\\\"$v\\\" | 0]\"", "->", "\"[:\\\"$v\\\" | 1]\"", []],
               ["\"[:\\\"$v\\\" | 1]\"", "->", "\"[:\\\"$v\\\" | 0]\"", []]
             ]
    end

    test "with attributes", ctx do
      :digraph.add_edge(ctx.digraph, ctx.v1, ctx.v2, foo: :bar)
      :digraph.add_edge(ctx.digraph, ctx.v2, ctx.v1, fiz: "buz")

      [
        "digraph",
        " {",
        [[], [], [], []],
        [],
        nodes,
        edges,
        "}"
      ] = Digraphviz.convert(ctx.digraph)

      assert Enum.sort(nodes, &sort_by_first/2) == [
               ["\"[:\\\"$v\\\" | 0]\"", []],
               ["\"[:\\\"$v\\\" | 1]\"", []]
             ]

      assert Enum.sort(edges, &sort_by_first/2) == [
               [
                 "\"[:\\\"$v\\\" | 0]\"",
                 "->",
                 "\"[:\\\"$v\\\" | 1]\"",
                 [" [", ["foo=bar"], "];"]
               ],
               [
                 "\"[:\\\"$v\\\" | 1]\"",
                 "->",
                 "\"[:\\\"$v\\\" | 0]\"",
                 [" [", ["fiz=\"buz\""], "];"]
               ]
             ]
    end
  end

  describe "Subgraphs" do
    setup ctx do
      :digraph.add_vertex(ctx.digraph, "1", subgraph: :foo)
      :digraph.add_vertex(ctx.digraph, "2", subgraph: {:foo, :bar})
      :digraph.add_vertex(ctx.digraph, "3", subgraph: {:foo, :baz})
      :digraph.add_vertex(ctx.digraph, "4", subgraph: {:foo, :bar, :fiz})
      :digraph.add_vertex(ctx.digraph, "5", subgraph: {:foo, :bar, :quick})
      :ok
    end

    test "without attributes", ctx do
      assert Digraphviz.convert(ctx.digraph) ==
               [
                 "digraph",
                 " {",
                 [[], [], [], []],
                 [
                   [
                     "subgraph ",
                     "\":foo\"",
                     " {",
                     [],
                     [
                       ["subgraph ", "\":baz\"", " {", [], [], [["\"3\"", []]], "}"],
                       [
                         "subgraph ",
                         "\":bar\"",
                         " {",
                         [],
                         [
                           ["subgraph ", "\":quick\"", " {", [], [], [["\"5\"", []]], "}"],
                           ["subgraph ", "\":fiz\"", " {", [], [], [["\"4\"", []]], "}"]
                         ],
                         [["\"2\"", []]],
                         "}"
                       ]
                     ],
                     [["\"1\"", []]],
                     "}"
                   ]
                 ],
                 [],
                 [],
                 "}"
               ]
    end

    test "with attributes", ctx do
      assert Digraphviz.convert(ctx.digraph, :digraph, [], %{
               foo: %{
                 attributes: [
                   graph: [fill: "orange"],
                   node: [color: "yellow"],
                   edge: [color: "magenta"]
                 ],
                 bar: %{
                   quick: %{
                     attributes: [node: [color: "gold"], label: "My shiny node"]
                   }
                 }
               }
             }) ==
               [
                 "digraph",
                 " {",
                 [[], [], [], []],
                 [
                   [
                     "subgraph ",
                     "\":foo\"",
                     " {",
                     [
                       ["graph", [" [", ["fill=\"orange\""], "];"]],
                       ["node", [" [", ["color=\"yellow\""], "];"]],
                       ["edge", [" [", ["color=\"magenta\""], "];"]],
                       []
                     ],
                     [
                       ["subgraph ", "\":baz\"", " {", [], [], [["\"3\"", []]], "}"],
                       [
                         "subgraph ",
                         "\":bar\"",
                         " {",
                         [],
                         [
                           [
                             "subgraph ",
                             "\":quick\"",
                             " {",
                             [
                               [],
                               ["node", [" [", ["color=\"gold\""], "];"]],
                               [],
                               [["label=\"My shiny node\""], ";"]
                             ],
                             [],
                             [["\"5\"", []]],
                             "}"
                           ],
                           ["subgraph ", "\":fiz\"", " {", [], [], [["\"4\"", []]], "}"]
                         ],
                         [["\"2\"", []]],
                         "}"
                       ]
                     ],
                     [["\"1\"", []]],
                     "}"
                   ]
                 ],
                 [],
                 [],
                 "}"
               ]
    end
  end
end

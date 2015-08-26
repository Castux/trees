require "tree"
require "graph"

foo = make_all_trees(6)[7]

print("Orig", foo.namestring)

bar = tree_to_graph(foo)


meh = graph_to_all_trees(bar)

for i,v in ipairs(meh) do
	print(v.namestring)
end
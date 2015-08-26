require "tree"
require "graph"
require "free"

res = make_all_free_trees(8)

for i,t in ipairs(res) do
	print(t.namestring)
end
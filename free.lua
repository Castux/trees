require "tree"
require "graph"

local gTreeToClass = {}

function classify_trees(trees)

	local classes = {}

	for _,tree in ipairs(trees) do

		if not gTreeToClass[tree] then

			local graph = tree_to_graph(tree)
			local class = graph_to_all_trees(graph)

			sort_trees(class)

			for _,t in ipairs(class) do
				gTreeToClass[t] = class
			end

			table.insert(classes, class)
		end
	end

	return classes
end

local gFreeTrees = {}

function make_all_free_trees(size)

	if gFreeTrees[size] then
		return gFreeTrees[size]
	end

	local result = {}

	local trees = make_all_trees(size)
	local classes = classify_trees(trees)

	for _,class in ipairs(classes) do
		table.insert(result, class[1])
	end

	gFreeTrees[size] = result
	return result
end
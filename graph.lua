-----------
-- Graph --
-----------

-- A graph is a list of nodes
-- A node is a list of its neighbour nodes

-- We use this representation to build classes
-- of rooted trees that have the same free tree
-- equivalent

function tree_to_graph(tree)

	local g = {}	-- list of nodes

	local function rec(tree)

		local node = {}

		for i,child in ipairs(tree.children) do

			local subnode = rec(child)
			table.insert(node, subnode)
			table.insert(subnode, node)
		end

		table.insert(g, node)
		return node
	end

	rec(tree)
	return g
end

function graph_to_tree(root)

	local visited = {}

	local function rec(node)

		if visited[node] then
			return
		end

		visited[node] = true

		local children = {}

		for i,v in ipairs(node) do
			local child = rec(v)

			if child then
				table.insert(children, child)
			end
		end

		return make_tree(children)
	end

	return rec(root)
end

function graph_to_all_trees(graph)

	local result = {}
	local found = {}

	for i,node in ipairs(graph) do

		local tree = graph_to_tree(node)

		if not found[tree] then
			found[tree] = true
			table.insert(result, tree)
		end
	end

	return result
end

function tree_to_edges(tree)
	
	local edges = {}
	local index = 0
	
	local function rec(tree)
		
		index = index + 1
		local thisIndex = index
		
		for i,child in ipairs(tree.children) do
			local childIndex = rec(child)
			table.insert(edges, {thisIndex, childIndex})
		end
		
		return thisIndex
	end
	
	rec(tree)
	return edges
end
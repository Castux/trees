---------------
-- Utilities --
---------------

function append_array(a,b)
	for i,v in ipairs(b) do
		table.insert(a,v)
	end
end

--------------------
-- Tree structure --
--------------------

local gTrees = {}	-- indexed by namestring

function name_to_namestring(name)
	return table.concat(name, "-")
end

-- build tree out of list of children

function make_tree(children)

	local tree = {}

	-- add children in decreasing order

	tree.children = children or {}

	sort_trees(tree.children)

	-- build name and compute size

	local size = 1
	local name = {1}

	for i,child in ipairs(tree.children) do
		size = size + child.size
		append_array(name, child.name)
	end

	tree.size = size
	name[1] = size

	tree.name = name
	tree.namestring = name_to_namestring(name)

	-- internize

	if not gTrees[tree.namestring] then
		gTrees[tree.namestring] = tree
	end

	return gTrees[tree.namestring]
end

function sort_trees(array)

	table.sort(array, function(a,b)
		return a.namestring > b.namestring
	end)
end

----------------
-- Generation --
----------------

local one = make_tree()

local gTreesBySize = {}
gTreesBySize[1] = {one}

function make_all_trees(size)

	if gTreesBySize[size] then
		return gTreesBySize[size]
	end

	local result = {}
	local found = {}	-- to avoid duplicates

	local forests = make_all_forests(size - 1)
	for i,forest in ipairs(forests) do

		local tree = make_tree(forest)

		if not found[tree] then
			found[tree] = true
			table.insert(result, tree)
		end
	end

	gTreesBySize[size] = result
	return result
end

local gForests = {}
gForests[0] = { {} }

function make_all_forests(size)

	if gForests[size] then
		return gForests[size]
	end

	local result = {}

	for N = 1,size do

		-- match all trees of size N with all forests of size size-N
		local trees = make_all_trees(N)
		local forests = make_all_forests(size - N)

		for _,tree in ipairs(trees) do
			for _,forest in ipairs(forests) do

				local tmp = {tree}
				append_array(tmp, forest)

				table.insert(result, tmp)

			end
		end

	end

	gForests[size] = result
	return result
end
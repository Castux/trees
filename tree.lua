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

-- All trees are internized, and immutable
-- That way we can reuse trees in bigger trees
-- and save a lot of memory and processing (no
-- need to copy trees, ever)

local gTrees = {}	-- indexed by namestring

function name_to_namestring(name)
	return table.concat(name, "-")
end

-- Build tree out of list of children
-- The list will used directly and sorted
-- Pass nil or an empty list to make the 1 tree

function make_tree(children)

	local tree = {}

	-- add children in decreasing order

	tree.children = children or {}
	sort_trees_decr(tree.children)

	-- build name and compute size

	local size = 1
	local name = {1}
	local curlies = {}

	for i,child in ipairs(tree.children) do
		size = size + child.size
		append_array(name, child.name)
		table.insert(curlies, child.curly)
	end

	tree.size = size
	name[1] = size

	tree.name = name
	tree.namestring = name_to_namestring(name)
	tree.curly = "{" .. table.concat(curlies, ",") .. "}"

	-- internize

	if not gTrees[tree.namestring] then
		gTrees[tree.namestring] = tree
	end

	return gTrees[tree.namestring]
end

-- The sorting order used throughout the library

function compare_trees(a,b)

	if a == b then
		return false
	end

	for i = 1, math.max(a.size, b.size) do
		
		if a.name[i] == nil then
			return true
		elseif b.name[i] == nil then
			return false
		elseif a.name[i] ~= b.name[i] then
			return a.name[i] < b.name[i]
		end
	end

	return false
end

function compare_trees_decr(a,b)
	return compare_trees(b,a)
end

function sort_trees(array)
	table.sort(array, compare_trees)
end

function sort_trees_decr(array)
	table.sort(array, compare_trees_decr)
end

------------------
-- Name to tree --
------------------

function name_to_tree(name)

	local function rec(index)

		if index > #name then
			return nil
		end

		local size = name[index]
		local children = {}
		local iter = index + 1

		while iter < index + size do
			local child = rec(iter)

			if not child then
				return nil
			end

			iter = iter + child.size
			table.insert(children, child)
		end

		return make_tree(children)
	end

	return rec(1)
end

----------------
-- Generation --
----------------

-- Generation is done bottom up: to make all trees of size N,
-- build all forests of size N-1 and set them as children of new trees.
-- Forest generation is recursive too: match all trees of size k with all
-- forests of size N-k, with k from 1 to N, forgetting duplicates on the way.

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
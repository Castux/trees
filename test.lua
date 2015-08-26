require "trees"

count = 0

for size = 1,5 do

	local trees = make_all_trees(size)

	for i,tree in ipairs(trees) do
		count = count + 1
		print(count, tree.namestring)
	end

end
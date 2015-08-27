require "tree"
require "draw"

-- Generate standalone SVGs from a few names

function make_a_few_images()

	local names = {
		{3,2,1},
		{4,3,1,1},
		{6,5,4,2,1,1},
		{8,7,5,1,1,1,1,1},
		{15,14,13,12,8,4,3,1,1,2,1,1,3,1,1}
	}

	for i,name in ipairs(names) do
		local tree = name_to_tree(name)

		local fp = io.open("www/img/" .. tree.namestring .. ".svg", "w")
		fp:write(tree_to_svg(tree, true))
		fp:close()
	end
end

-- An example of how the webpages were generated

function generate_pages()

	local fp = io.open("1-12.html", "w")
	make_html(fp,1,12)
	fp:close()

	for i = 13,15 do
		print("Treating " .. i)
		fp = io.open(i .. ".html", "w")
		make_html(fp, i)
		fp:close()
	end
end
require "free"
require "draw"

local html_header = [[
<!DOCTYPE html>
<html>
<head>
	<meta charset="utf-8">
	<title>%s</title>
</head>
<body>
]]

local html_title = [[
<h1>Size %d</h1>
]]

local html_footer = [[
</body>
</html>
]]

---------------
-- Make HTML --
---------------

-- Write an HTML5 page with embedded SVGs of all trees
-- in the given size range. Adds separation H1 titles.

-- Takes an open file descriptor object

function make_html(fp, min_size, max_size)

	max_size = max_size or min_size

	local title = "Trees of size " .. min_size

	if min_size < max_size then
		title = title .. " to " .. max_size
	end

	fp:write(string.format(html_header, title))

	for size = min_size,max_size do

		fp:write(string.format(html_title, size))

		local trees = make_all_free_trees(size)

		for _,tree in ipairs(trees) do
			local svg = tree_to_svg(tree)
			fp:write(svg, '\n')
		end
	end

	fp:write(html_footer)
end
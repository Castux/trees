require "free"

config = {
	N = 10,
	titles = true,
	type = "free",
	output = "names"
}

-- command line parsing

args = {...}

usage_text = [[
Free tree generator. Usage:
lua tool.lua [-N size] [--rooted] [--notitles] [--luatables]
lua tool.lua [-h | --help]

-N size:	generate trees up to size N
--rooted:	generate rooted trees instead of free trees
--notitles:	output only the trees, no formating
--luatables	output trees as Lua tables
--help, -h:	display this help
]]

for i,v in ipairs(args) do

	if v == "--notitles" then
		config.titles = false
	
	elseif v == "-N" then
		config.N = tonumber(args[i+1])
		if config.N == nil then
			error("Wrong argument for -N: " .. args[i+1])
		end

	elseif v == "--rooted" then
		config.type = "rooted"
	
	elseif v == "--luatables" then
		config.output = "tables"

	elseif v == "--help" or v == "-h" then
		print(usage_text)
		os.exit(0)
	end
end

-- generation

for i = 1,config.N do

	if config.titles then
		local title = "Size " .. i
		print(title)
		print(string.rep("=", #title))
		print()
	end

	local trees

	if config.type == "rooted" then
		trees = make_all_trees(i)
	else
		trees = make_all_free_trees(i)
	end

	for _,tree in ipairs(trees) do
		print(config.output == "names" and tree.namestring or tree.curly)
	end

	if config.titles then
		print()
	end
end
local vertices = {1}
local edges = {}


function newV()
	
	local v = #vertices + 1
	table.insert(vertices, v)
	
	return v
end

function printEdges()
	
	local res = {}
	
	for i,v in ipairs(edges) do
		table.insert(res, string.format("(%d,%d)", v[1], v[2]))
	end
	
	print(table.concat(res))
end


local current = {1}

for level = 1,7 do
	
	local nextV = {}
	
	for _,index in ipairs(current) do
		
		local l = newV()
		local r = newV()
		
		table.insert(edges, {index, l})
		table.insert(edges, {index, r})
		
		table.insert(nextV, l)
		table.insert(nextV, r)
		
	end
	
	for i = 1,#nextV - 1 do
		table.insert(edges, {nextV[i], nextV[i+1]})
	end
	
	current = nextV
end

printEdges()
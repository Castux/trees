-- Mesh

local lastIndex = 0
function newIndex()
		lastIndex = lastIndex + 1
	return lastIndex
end


local edges = {}
local vertices = {}

vertices[0] = { {newIndex(), "B"} }
vertices[1] = {}


function firstLayer(index, verts)
	
	local these = {}
	
	for i = 1,10 do
		table.insert(these, {newIndex(), i % 2 == 0 and "B" or "b" })
		
		if i % 2 == 0 then
			table.insert(edges, {index, these[#these][1]})
		end		
	end
	
	for i = 1,#these-1 do
		table.insert(edges, { these[i][1], these[i+1][1] })
	end
	table.insert(edges, { these[1][1], these[#these][1] })
	
	for i,v in ipairs(these) do
		table.insert(verts, v)
	end	
end

function doB(index, verts)
		
	local a = {newIndex(), "B"}
	local b = {newIndex(), "b"}
	local c = {newIndex(), "B"}
	
	table.insert(verts, a)
	table.insert(verts, b)
	table.insert(verts, c)
	
	table.insert(edges, {index, a[1]})
	table.insert(edges, {a[1], b[1]})
	table.insert(edges, {b[1], c[1]})
	table.insert(edges, {c[1], index})
	
	return a[1],c[1]
end

function dob(index, verts)
	
	local a = {newIndex(), "B"}
	local b = {newIndex(), "b"}
	local c = {newIndex(), "B"}
	local d = {newIndex(), "b"}
	local e = {newIndex(), "B"}

	table.insert(verts, a)
	table.insert(verts, b)
	table.insert(verts, c)
	table.insert(verts, d)
	table.insert(verts, e)
	
	table.insert(edges, {a[1], b[1]})
	table.insert(edges, {b[1], c[1]})
	table.insert(edges, {c[1], d[1]})
	table.insert(edges, {d[1], e[1]})

	table.insert(edges, {index, a[1]})
	table.insert(edges, {index, c[1]})
	table.insert(edges, {index, e[1]})
	
	return a[1],e[1]
end

function iter()

	local newVertices = {}

	local first
	local last

	for i,v in ipairs(vertices[#vertices]) do
		
		local f,l
		
		if v[2] == "B" then
			f,l = doB(v[1], newVertices)
			
			
		
		elseif v[2] == "b" then
		
			f,l = dob(v[1], newVertices)
		
		end
	
		if not first then
			first = f
		end
		
		if last then
			table.insert(edges, {last, f})
		end
		
		last = l
		
		if i == #vertices[#vertices] then
			table.insert(edges, {last, first})
		end
	end
	
	table.insert(vertices, newVertices)
end

function printAll()
	
	local res = {}
	for i,v in ipairs(edges) do
		table.insert(res, string.format("(%d,%d)", v[1], v[2]))
	end
	
	print(table.concat(res))
end

function makeDot()
	local res = {}
	
	table.insert(res, "graph G {")
	table.insert(res, "graph [ dimen=3 ];")
	
	for i,v in ipairs(edges) do
		table.insert(res, string.format("%s -- %s;", v[1], v[2]))
	end
	
	table.insert(res, "}")
	
	local fp = io.open("out.dot", "w")
	fp:write(table.concat(res, "\n"))
	fp:close()
end

-- Prog!

firstLayer(vertices[0][1][1], vertices[1])
iter()
iter()
--iter()

printAll()
makeDot()
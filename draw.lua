require "graph"

-- Physical parameters

local L = 20
local K = 20
local drag = 0.02
local dt = 0.1

-- Shortcuts

local rand = math.random
local sqrt = math.sqrt

-----------------
-- Tree layout --
-----------------

function layout_tree(tree)

	local nodes = tree_to_graph(tree)
	local N = #nodes

	-- Adjancency matrix

	local adj = {}
	for _,node in ipairs(nodes) do
		
		adj[node] = {}

		for _,neighbour in ipairs(node) do
			adj[node][neighbour] = true
		end
	end

	local converged
	local iter

	local function init()

		-- Nodes setup

		for i,node in ipairs(nodes) do
			node.x = rand()*2 - 1
			node.y = rand()*2 - 1
			node.vx = 0
			node.vy = 0
			node.ax = 0
			node.ay = 0
			node.id = i
		end

		-- Iteration setup

		converged = false
		iter = 0
	end

	-- Iteration

	init()

	while true do

		-- apply forces, mwaha
		for i = 1,N do
			for j = i+1,N do
				
				local a = nodes[i]
				local b = nodes[j]
				
				-- force i -> j
				local dx = b.x - a.x
				local dy = b.y - a.y
				
				local d = sqrt(dx^2 + dy^2)
				local f
							
				-- neighbours
				if adj[a][b] then
				
					f = -K * (d - L)
					
				-- not neighbours
				else
					f = 5*K/d
				end
				
				b.ax = b.ax + f*dx/d
				b.ay = b.ay + f*dy/d
				
				a.ax = a.ax - f*dx/d
				a.ay = a.ay - f*dy/d
				
			end
		end
		
		local sum = 0
		
		-- Integrate movement

		for i = 1,#nodes do
			local v = nodes[i]
			
			v.vx = v.vx + v.ax * dt - drag * v.vx
			v.vy = v.vy + v.ay * dt - drag * v.vy
			
			local dx = v.vx * dt
			local dy = v.vy * dt
			
			v.x = v.x + dx
			v.y = v.y + dy
			
			sum = sum + v.vx^2 + v.vy^2
			
			-- clear accels for next round
			v.ax = 0
			v.ay = 0
		end
		
		-- Count

		iter = iter + 1

		-- Check convergence
		
		if sum/#nodes < 0.05 then
			break
		end

		-- Check non convergence

		if iter > 2000 then
			print("Time out for " .. tree.namestring .. ", reinit.")
			init()
		end
	end

	-- Cleanup

	for i,v in ipairs(nodes) do
		v.x = math.ceil(v.x)
		v.y = math.ceil(v.y)
		v.vx = nil
		v.vy = nil
		v.ax = nil
		v.ay = nil
	end

	return nodes
end

----------------
-- SVG output --
----------------

function tree_to_svg(tree)

	local nodes = layout_tree(tree)

	local margin = 30

	-- Compute bounding box
	
	local xs,ys = {},{}

	for i,v in ipairs(nodes) do
		table.insert(xs, v.x)
		table.insert(ys, v.y)
	end
	
	table.sort(xs)
	table.sort(ys)
	
	local w = xs[#xs] - xs[1] + 2 * margin
	local h = ys[#ys] - ys[1] + 2 * margin

	-- Translate all nodes to positive values
	
	for i,v in ipairs(nodes) do
		v.x = v.x - xs[1] + margin
		v.y = v.y - ys[1] + margin
	end

	-- Write SVG

	svg = [[
<?xml version="1.0" encoding="utf-8"?>
<svg
	xmlns="http://www.w3.org/2000/svg" 
	version="1.1"
]]

	svg = svg .. '\twidth="' .. w .. '"\n'
	svg = svg .. '\theight="' .. h .. '">\n'
	
	svg = svg .. '\t<title>' .. tree.namestring .. '</title>\n'

	for _,node in ipairs(nodes) do
		svg = svg .. string.format('<circle cx="%d" cy="%d" r="5" fill="black" />\n', node.x, node.y)

		for _,neighbour in ipairs(node) do
			if node.id < neighbour.id then
				svg = svg .. string.format('<line x1="%d" y1="%d" x2="%d" y2="%d" stroke="black" stroke-width="2" />\n',
					node.x, node.y, neighbour.x, neighbour.y)
			end
		end
	end

	svg = svg .. '</svg>'

	return svg
end
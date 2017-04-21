var textBox;
var indices;
var matrix;
var points;
var drawing;

function main()
{
	textBox = document.getElementById("dots");
	textBox.onchange = onInputChange;

	drawing = document.getElementById("drawing");
	drawing.onclick = update;

	onInputChange();
	update();
}

function onInputChange()
{
	handleInput();
	prepareSimulation();
	draw();
}

function update()
{
	console.log("update");
	iterate();
	draw();
	window.requestAnimationFrame(update);
}

function hash(pair)
{
	pair = pair.sort();
	return pair[0] + ":" + pair[1];
}

function neighbours(i,j)
{
	return matrix[hash([i,j])] != null;
}

function handleInput()
{
	var txt = textBox.value;
	var regex = /\((\d+),(\d+)\)/gm

	indices = new Set();
	matrix = {};

	var match;
	while(match = regex.exec(txt))
	{
		let i1 = parseInt(match[1]);
		let i2 = parseInt(match[2]);

		indices.add(i1);
		indices.add(i2);

		let pair = [i1,i2].sort();
		matrix[hash(pair)] = pair;
	}
}

function randomPoint()
{
	return [Math.random() * 100, Math.random() * 100];
}

function prepareSimulation()
{
	points = {}
	for(let index of indices)
	{
		points[index] = randomPoint();
	}
}

function iterate()
{
	let K = 0.3;
	let L = 20;

	let alpha = 0.75;

	// Compute

	let forces = {};

	for(let i of indices)
	{
		let fx = 0;
		let fy = 0;

		for(let j of indices)
		{
			if(i == j)
				continue;

			let a = points[i];
			let b = points[j];

			let dx = b[0] - a[0];
			let dy = b[1] - a[1];
			let d = Math.sqrt(dx * dx + dy * dy);

			let f = 0;

			if(neighbours(i,j))
			{
				f = - K * (d - L);
			}
			else
			{
				f = 20 * K / d;
			}

			fx -= f * dx/d;
			fy -= f * dy/d;
		}

		forces[i] = [fx, fy];
	}

	// Apply

	for(let i of indices)
	{
		points[i][0] += forces[i][0] * alpha;
		points[i][1] += forces[i][1] * alpha;
	}
}

function addDot(pos)
{
	var dot = document.createElementNS("http://www.w3.org/2000/svg", "circle");
	dot.setAttribute('cx', pos[0]);
	dot.setAttribute('cy', pos[1]);
	dot.setAttribute('r', 5);
	dot.setAttribute('fill','black');

	drawing.appendChild(dot);
}

function addLine(pos1, pos2)
{
	var line = document.createElementNS("http://www.w3.org/2000/svg", "line");
	line.setAttribute('x1', pos1[0]);
	line.setAttribute('y1', pos1[1]);
	line.setAttribute('x2', pos2[0]);
	line.setAttribute('y2', pos2[1]);
	line.setAttribute('stroke', 'black');
	line.setAttribute('stroke-width', 2);

	drawing.appendChild(line);
}

function findBounds()
{
	let xmin = 1e9;
	let xmax = -1e9;
	let ymin = 1e9;
	let ymax = -1e9;

	for(let index in points)
	{
		let p = points[index];
		if(p[0] < xmin) xmin = p[0];
		if(p[0] > xmax) xmax = p[0];
		if(p[1] < ymin) ymin = p[1];
		if(p[1] > ymax) ymax = p[1];
	}

	return [xmin, xmax, ymin, ymax];
}

function draw()
{
	drawing.innerHTML = "";

	let margin = 30;

	let bounds = findBounds();
	let w = bounds[1] - bounds[0] + 2 * margin;
	let h = bounds[3] - bounds[2] + 2 * margin;

	drawing.setAttribute('width', w);
	drawing.setAttribute('height', h);

	for(let index of indices)
	{
		points[index][0] -= bounds[0] - margin;
		points[index][1] -= bounds[2] - margin;
		addDot(points[index]);
	}
	
	for(let key in matrix)
	{
		let pair = matrix[key];
		addLine(points[pair[0]], points[pair[1]]);
	}
}
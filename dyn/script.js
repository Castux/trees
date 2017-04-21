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
	drawing.onclick = onInputChange;

	setup3D();
	onInputChange();
	update();
}

function onInputChange()
{
	handleInput();
	prepareSimulation();
	prepareSimulation3D();
}

function update()
{
	iterate();
	draw();

	iterate3D();
	draw3D();

	window.requestAnimationFrame(update);
}

function getFloat(name)
{
	return parseFloat(document.getElementById(name).value);
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
	let K = getFloat("K");
	let L = getFloat("L");
	let alpha = getFloat("alpha");

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
	let w = 400;

	let bounds = findBounds();
	let cx = (bounds[1] + bounds[0])/2;
	let cy = (bounds[3] + bounds[2])/2;

	drawing.setAttribute('width', w);
	drawing.setAttribute('height', w);

	for(let index of indices)
	{
		points[index][0] += w / 2 - cx;
		points[index][1] += w / 2 - cy;
		addDot(points[index]);
	}
	
	for(let key in matrix)
	{
		let pair = matrix[key];
		addLine(points[pair[0]], points[pair[1]]);
	}
}

// Threedee

var scene;
var camera;
var renderer;

var sphereGeom;
var material;

var spheres;

function setup3D()
{
	let params = {canvas: document.getElementById("3ddrawing")};
	renderer = new THREE.WebGLRenderer(params);
	renderer.setSize(400, 400);

	sphereGeom = new THREE.SphereGeometry(5, 10, 10);
	material = new THREE.MeshBasicMaterial({color: 0xFFFFFF});
}

function randomPoint3D()
{
	return new THREE.Vector3(Math.random() * 100, Math.random() * 100, Math.random() * 100);
}

function prepareSimulation3D()
{
	points3D = {};
	spheres = {};

	scene =	new THREE.Scene();
	camera = new THREE.PerspectiveCamera(75, 1, 0.1, 1000);
	scene.add(camera);

	for(let index of indices)
	{		
		let sphere = new THREE.Mesh(sphereGeom);
		sphere.position.copy(randomPoint3D());
		spheres[index] = sphere;
		scene.add(sphere);
	}
}

function iterate3D()
{
	let K = getFloat("K");
	let L = getFloat("L");
	let alpha = getFloat("alpha");

	// Compute

	let forces = {};

	for(let i of indices)
	{
		let f = new THREE.Vector3();

		for(let j of indices)
		{
			if(i == j)
				continue;

			let a = spheres[i].position;
			let b = spheres[j].position;

			let delta = b.clone().sub(a);
			let d = delta.length();
			delta.normalize();

			let intensity = 0;

			if(neighbours(i,j))
			{
				intensity = - K * (d - L);
			}
			else
			{
				intensity = 20 * K / d;
			}

			delta.multiplyScalar(intensity).negate();

			f.add(delta);
		}

		forces[i] = f;
	}

	// Apply

	for(let i of indices)
	{
		spheres[i].position.add(forces[i].multiplyScalar(alpha));
	}	
}

var t = 0;

function draw3D()
{
	t++;
	let R = 150;

	// auto camera

	let center = new THREE.Vector3();

	for(let index of indices)
	{
		center.add(spheres[index].position);
	}

	center.divideScalar(indices.size);

	let phi = t / (60 * 10) * Math.PI * 2;
	let pos = center.clone().add(new THREE.Vector3(R * Math.cos(phi), 0, R * Math.sin(phi)));

	camera.position.copy(pos);
	camera.lookAt(center);

	renderer.render(scene, camera);
}
FPSCounter = (ctx) ->
	@t = new Date().getTime() / 1000.0
	@n = 0
	@fps = 0.0
	@draw = ->
		@n++
		if @n == 10
			@n = 0
			t = new Date().getTime() / 1000.0
			@fps = Math.round(100 / (t - @t)) / 10
			@t = t
		ctx.fillStyle = "white"
		ctx.fillText "FPS: " + @fps, 1, 15

window.Float32Array = Array unless window.Float32Array
WIDTH = 800
HEIGHT = 600
NPARTICLES = 10000
CELLSIZE = 20
CELLSIZE2 = CELLSIZE / 2
color_mode = 0

modeSwap = (newMode) ->
	color_mode = newMode
window.modeSwap = modeSwap	

canvas = document.getElementById("c")
screenRatio = 1.0
if navigator.userAgent.match(/iPad/i)
	WIDTH = 320
	HEIGHT = 240
	NPARTICLES /= 5
	screenRatio = WIDTH / 640
	canvas.style.width = "640px"
	canvas.style.height = "480px"
	document.getElementById("d").style.width = canvas.style.width
	document.getElementById("d").style["margin-top"] = "30px"
else if navigator.userAgent.match(/iPhone|iPod|Android/i)
	WIDTH = 320
	HEIGHT = 200
	NPARTICLES /= 5
	screenRatio = WIDTH / window.innerWidth
	canvas.style.width = "100%"
	canvas.style.height = innerHeight + "px"
	document.getElementById("d").style.width = canvas.style.width
	document.getElementById("d").style.border = 0
	if navigator.userAgent.match(/Android/i)
		canvas.style.height = "1000px"
		setTimeout ->
			window.scrollTo 0, window.innerHeight
			setTimeout ->
				canvas.style.height = document.documentElement.clientHeight + "px"
			, 1
		, 100
ctx = canvas.getContext("2d")
particles = new Float32Array(NPARTICLES * 4)
flow = new Float32Array(WIDTH * HEIGHT / CELLSIZE / CELLSIZE * 2)

CELLS_X = WIDTH / 20
floor = Math.floor

i=0
while i < particles.length
	particles[i++] = Math.random() * WIDTH
	particles[i++] = Math.random() * HEIGHT
	particles[i++] = 0
	particles[i++] = 0

i = 0
while i < flow.length
	flow[i] = 0
	i++

start = 
	x: 0
	y: 0

down = true
canvas.onmousedown = (e) ->
	start.x = (e.clientX - canvas.offsetLeft) * screenRatio
	start.y = e.clientY - canvas.offsetTop * screenRatio
	down = true

canvas.ontouchstart = (e) ->
	canvas.onmousedown e.touches[0]
	false

canvas.onmouseup = canvas.ontouchend = ->
	down = false

canvas.ontouchmove = (e) ->
	canvas.onmousemove e.touches[0]

canvas.onmousemove = (e) ->
	mx = (e.clientX - canvas.offsetLeft) * screenRatio
	my = (e.clientY - canvas.offsetTop) * screenRatio
	return	if not down or mx == start.x and my == start.y
	ai = (floor(mx / CELLSIZE) + floor(my / CELLSIZE) * floor(WIDTH / CELLSIZE)) * 2
	flow[ai] += (mx - start.x) * 0.4
	flow[ai + 1] += (my - start.y) * 0.4
	start.x = mx
	start.y = my

# rcolors = ["rgba(255,0,0,0.8)","rgba(255,255,255,0.8)","rgba(255,255,0,0.8)"]
colors1 = ["rgba(30,30,100,0.8)","rgba(40,40,120,0.8)","rgba(60,60,140,0.8)","rgba(80,80,160,0.8)","rgba(100,100,180,0.8)","rgba(100,100,210,0.8)","rgba(100,100,230,0.8)"]
colors2 = ["rgba(220,0,0,0.8)","rgba(220,100,0,0.8)","rgba(220,220,180,0.8)","rgba(0,220,0,0.8)","rgba(0,0,220,0.8)","rgba(100,0,180,0.8)","rgba(220,60,220,0.8)"]

setInterval ->
	vd = 0.95
	ad = 0.95
	ar = 0.004
	w1 = WIDTH - 1
	ctx.fillStyle = "rgba(0, 0, 0, 0.6)"
	ctx.globalCompositeOperation = "source-over"
	ctx.fillRect 0, 0, WIDTH, HEIGHT
	ctx.globalCompositeOperation = "lighter"
	i = 0
	l = particles.length

	#fixed color
	if color_mode == 0 
		ctx.fillStyle = "rgba(120,120,255,0.8)"
	else if color_mode == 1
		useColors = colors1
	else 
		useColors = colors2

	while i < l
		x  = particles[i]
		y  = particles[i + 1]
		vx = particles[i + 2]
		vy = particles[i + 3]
		ai = (~~(x / CELLSIZE) + ~~(y / CELLSIZE) * CELLS_X) * 2
		ax = flow[ai]
		ay = flow[ai + 1]
		ax = (ax + vx * ar) * ad
		ay = (ay + vy * ar) * ad
		vx = (vx + ax) * vd
		vy = (vy + ay) * vd


		#random colors
		#v1 = vx*vx + vy*vy 
#		if v1 < 1
#			ctx.fillStyle = "rgba("+~~(Math.random()*100+80)+","+~~(Math.random()*100+80)+","+~~(Math.random()*175+80)+",0.8)"
#		else
#			ctx.fillStyle = rcolors[~~(Math.random()*rcolors.length)]

		if color_mode > 0
			# velocity based colors
			v1 = vx*vx + vy*vy 
			if v1 < 1
				ctx.fillStyle = useColors[~~(Math.random()*useColors.length)]
			else if v1 < 4
				ctx.fillStyle = useColors[0]
			else if v1 < 9
				ctx.fillStyle = useColors[1]
			else if v1 < 16
				ctx.fillStyle = useColors[2]
			else if v1 < 25
				ctx.fillStyle = useColors[3]
			else if v1 < 36
				ctx.fillStyle = useColors[4]
			else if v1 < 64
				ctx.fillStyle = useColors[5]
			else
				ctx.fillStyle = useColors[6]
				
		x += vx
		y += vy
		ctx.fillRect ~~x, ~~y, 2, 2
		if x < 0
			vx *= -1
			x = 0
		else if x > w1
			x = w1
			vx *= -1
		if y < 0
			vy *= -1
			y = 0
		else if y > HEIGHT
			y = HEIGHT - 1
			vy *= -1
		particles[i] = x
		particles[i + 1] = y
		particles[i + 2] = vx
		particles[i + 3] = vy
		flow[ai] = ax
		flow[ai + 1] = ay
		i += 4
, 33
fps = new FPSCounter(ctx)
canvas.width = WIDTH
canvas.height = HEIGHT


import "importUtil"
ensureImport "tileUtil"

solid = []
for i in range(32, 64)
	solid.push i
end for
mud = [[0, 0.65], [1, 0.3], [4, 0.5]]
water = [[12, 0.4]]

act = 2
section = 2

started = false
checkpoints = []
laps = 3

levelPath = "/usr/levels/"

setup = function
	lvl = levelPath + act + "-" + section + ".dat"
	outer.name = act + "-" + section
	walls.clear
	ground.clear
	globals.path = []
	globals.path = globals.get("path" + section)
	objects.clear
	kart.clear
	
	tileUtil.loadFromFile lvl, walls, ground

	if section == 10 then
		tintLevel color.rgb(120, 70, 150)
	else if section > 7 then
		tintLevel color.rgb(170, 90, 150)
	else if section > 3 then
		tintLevel color.rgb(255, 200, 200)
	else
		tintLevel color.rgb(255, 255, 255)
	end if

	updatable.all = [player, player2]
	outer.checkpoints = []

	camera.update
	processLevel

	for c in globals.get("checkpoint" + section)
		checkpoint = new Bounds
		checkpoint.x = c[0] * ground.cellSize
		checkpoint.y = c[1] * ground.cellSize
		checkpoint.width = c[2] * ground.cellSize
		checkpoint.height = c[3] * ground.cellSize
		outer.checkpoints.push checkpoint
	end for
	player.updateSprites
	player2.updateSprites
	ui.getUpgrades(player)
	ui.getUpgrades(player2)
	if section == 1 then
		display(0).mode = displayMode.solidColor
		d = display(0)
		d.color = color.black
		for a in range(255, 0, -5)
		    d.color = color.rgba(0, 0, 0, a)
		    yield
		end for
	end if
	for i in range(3, 0, -1)
		txt = str(i)
		if i == 0 then txt = "GO!"
		gfx.clear
		gfx.print txt, 960/2, (640/2)-txt.len*10, color.white, "large"
		sound["announce"+i].play
		sound["announce"+i].adjust 0.2 * globals.soundVol
		wait 0.5
	end for
	gfx.clear
	ui.update player2
	ui.update player
end function

blocksWalking = function(x, y)
	// return whether the given pixel position is blocked from walking
	// (horizontal movement), i.e., there is a solid block there
	col = floor(x / ground.cellSize)
	row = floor(y / ground.cellSize)
	tile = walls.cell(col, row)
	tileRow = floor(tile / 16)
	tileCol = floor(tile % 16)
	if solid.indexOf(tile) != null then return true
	return false
end function

wallRaycast = function(start, target)
	stepSize = 16  // Step size for the ray
	currentPos = {"x":start[0], "y":start[1]}
	targetPos = {"x":target[0], "y":target[1]}
	
	direction = [target[0] - start[0], target[1] - start[1]]
	magnitude = sqrt(direction[0]^2 + direction[1]^2)
	direction[0] /= magnitude
	direction[1] /= magnitude
	
	while true
		// Calculate the next position
		mathUtil.moveTowardsXY currentPos, targetPos, stepSize
		
		cellX = floor(currentPos.x/64)
		cellY = floor(currentPos.y/64)
		// Check if the current position hits a wall
		if blocksWalking(currentPos.x, currentPos.y) then
			return {"x": cellX, "y": cellY}  // Intersection found
		end if
		
		// Check if the current position reaches the target
		if currentPos == targetPos then
			return null
		end if
	end while
end function


processLevel = function
	for y in range(0, walls.extent[1]-1)
		for x in range(0, walls.extent[0]-1)
			c = walls.cell(x, y)
			if c == 37 then
				player.lx = x*64 + 32
				player.ly = y*64 + 32
				player.vx = 0
				player.vy = 0
				player.bx = 0
				player.by = 0
				player.angle_degrees = 0
				player.rotation = 0
				player.driftBoost = 0
				walls.setCell x, y, 9
				player.currentLap = 1
				player.currentCheckpoint = 0
				player.handleModifiers
			else if c == 38 then
				player2.lx = x*64 + 32
				player2.ly = y*64 + 32
				player2.vx = 0
				player2.vy = 0
				player2.bx = 0
				player2.by = 0
				player2.angle_degrees = 0
				player2.rotation = 0
				player2.currentLap = 1
				player2.currentCheckpoint = 0
				player2.handleModifiers
				player2.pathPoint = pathUtil.PathPoint.make(globals.path, 0)
				walls.setCell x, y, 9
			else if c == 39 then
				objects.Coin.place x, y
			end if
		end for
	end for
end function

tintLevel = function(tint)
	for y in range(0, walls.extent[1]-1)
		for x in range(0, walls.extent[0]-1)
			walls.setCellTint x, y, tint
			ground.setCellTint x, y, tint
		end for
	end for
end function
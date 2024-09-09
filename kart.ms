import "importUtil"
ensureImport "camera"
ensureImport "particles"
ensureImport "stackedSprite"
ensureImport "mathUtil"
ensureImport "sound"
ensureImport "pathfinding"

findByType = function(lst, type)
    for item in lst
        if item isa type then return item
    end for
    return null
end function

Kart = new StackedSprite
Kart.lx = 480
Kart.ly = 320
Kart.lScale = 4
Kart.scale = 4
Kart.maxSpeed = 420
Kart.mudSpeed = 165
Kart.angle_degrees = 0
Kart.accel = 1050
Kart.decel = 400
Kart.driftAccel = 600
Kart.boostDecel = 300
Kart.turnSpeed = 200
Kart.localBounds = new Bounds
Kart.localBounds.width = 12
Kart.localBounds.height = 12
Kart.currentMaxSpeed = 450
Kart.coins = 0
Kart.score = 0
Kart.wins = 0

Kart.speedModifier = 1.0
Kart.accelModifier = 1.0
Kart.mudModifier = 1.0
Kart.scaleModifier = 1.0
Kart.weightModifier = 1.0
Kart.defenceTimer = 0
Kart.defenceTime = 1.75
Kart.shrinkTimer = 0
Kart.shrinkTime = 3
Kart.shootTimer = 0
Kart.shootTime = 2

Kart.dx = 0
Kart.dy = 0
Kart.vx = 0
Kart.vy = 0
Kart.bx = 0
Kart.by = 0
Kart.speed = 0
Kart.currentLap = 1
Kart.currentCheckpoint = 0
Kart.currentUpgrades = []

Kart.init = function
	disp.sprites.push self
	super.init
end function

Kart.reset = function(x, y)
	self.lx = x*64 + 32
	self.ly = y*64 + 32
	self.vx = 0
	self.vy = 0
	self.bx = 0
	self.by = 0
	self.angle_degrees = 0
	self.rotation = 0
	self.driftBoost = 0
	self.currentLap = 1
	self.currentCheckpoint = 0
	self.handleModifiers
end function

Kart.checkWalls = function
	if level.blocksWalking(self.x + (12*(self.scale/4)), self.y) then
		if self.checkCrate(self.x + (12*(self.scale/4)), self.y) == true then return
		self.lx = floor((self.lx + (12*(self.scale/4))) / camera.tileCellSize) * camera.tileCellSize - (12*(self.scale/4))
		// if self.angle_degrees > 30 or self.angle_degrees < -30 then self.velocity *= -0.5
		self.vx *= -0.6
		self.bx *= -0.6
		if abs(self.vx) > 70 then 
			sound.bump.play
			sound.bump.adjust 0.2 * globals.soundVol
		end if
	end if
	if level.blocksWalking(self.x - (12*(self.scale/4)), self.y) then
		if self.checkCrate(self.x - (12*(self.scale/4)), self.y) == true then return
		self.lx = ceil((self.lx - (12*(self.scale/4))) / camera.tileCellSize) * camera.tileCellSize + (12*(self.scale/4))
		self.vx *= -0.6
		self.bx *= -0.6
		if abs(self.vx) > 70 then 
			sound.bump.play
			sound.bump.adjust 0.2 * globals.soundVol
		end if
	end if
	if level.blocksWalking(self.x, self.y + (12*(self.scale/4))) then
		if self.checkCrate(self.x, self.y + (12*(self.scale/4))) == true then return
		self.ly = floor((self.ly + (12*(self.scale/4))) / camera.tileCellSize) * camera.tileCellSize - (12*(self.scale/4))
		self.vy *= -0.6
		self.by *= -0.6
		if abs(self.vy) > 70 then 
			sound.bump.play
			sound.bump.adjust 0.2 * globals.soundVol
		end if
	end if
	if level.blocksWalking(self.x, self.y - (12*(self.scale/4))) then
		if self.checkCrate(self.x, self.y - (12*(self.scale/4))) == true then return
		self.ly = ceil((self.ly - (12*(self.scale/4))) / camera.tileCellSize) * camera.tileCellSize + (12*(self.scale/4))
		self.vy *= -0.6
		self.by *= -0.6
		if abs(self.vy) > 70 then 
			sound.bump.play
			sound.bump.adjust 0.2 * globals.soundVol
		end if
	end if
	if self.lx * camera.tileCellSize / 64 < 0 then
        self.lx = 0
        self.vx *= -0.6
        self.bx *= -0.6
        if abs(self.vx) > 70 then 
			sound.bump.play
			sound.bump.adjust 0.2 * globals.soundVol
		end if
    end if
	if self.ly * camera.tileCellSize / 64 < 0 then
        self.ly = 0 
        self.vy *= -0.6
        self.by *= -0.6
        if abs(self.vy) > 70 then 
			sound.bump.play
			sound.bump.adjust 0.2 * globals.soundVol
		end if
    end if
	if self.lx * camera.tileCellSize / 64 > ground.extent[0] * camera.tileCellSize then 
		self.lx = ground.extent[0] * camera.tileCellSize 
		self.vx *= -0.6
        self.bx *= -0.6
        if abs(self.vx) > 70 then 
			sound.bump.play
			sound.bump.adjust 0.2 * globals.soundVol
		end if
	end if
	if self.ly * camera.tileCellSize / 64 > ground.extent[1] * camera.tileCellSize then 
		self.ly = ground.extent[1] * camera.tileCellSize
		self.vy *= -0.6
        self.by *= -0.6
        if abs(self.vy) > 70 then 
			sound.bump.play
			sound.bump.adjust 0.2 * globals.soundVol
		end if
	end if
end function

Kart.checkCrate = function(x, y)
	if abs(self.vx) + abs(self.vy) < 100 then return
	col = floor(x / camera.tileCellSize)
	row = floor(y / camera.tileCellSize)
	tile = walls.cell(col, row)
	if tile == 45 then
		if self.lScale >= 5 then
			walls.setCell(col, row, null)
			return true
		else
			walls.setCell(col, row, 46)
			return false
		end if
	else if tile == 46 then
		walls.setCell(col, row, null)
		return false
	end if
	return false
end function

Kart.handleModifiers = function
	spdMod = 1.0
	accelMod = 1.0
	sclMod = 1.0
	wghMod = 1.0
	mudMod = 0.9
	for u in self.currentUpgrades
		if u.name == "Compact Engines" then
			if u.level >= 1 then
				spdMod += 0.04
				sclMod -= 0.17
				accelMod += 0.1
			end if
			if u.level >= 2 then
				spdMod += 0.04
				wghMod += 0.6
				accelMod += 0.15
			end if
		else if u.name == "Grippier Wheels" then
			if u.level >= 1 then
				accelMod += 0.4
				sclMod += 0.05
			end if
			if u.level >=2 then
				accelMod += 0.2
				mudMod -= 0.7
			end if
		else if u.name == "Juggernaut" then
			if u.level >= 1 then
				accelMod += 0.2
				sclMod += 0.2
				spdMod -= 0.04
				wghMod += 1.2
			end if
		end if
	end for
	self.speedModifier = spdMod
	self.scaleModifier = sclMod
	self.weightModifier = wghMod
	self.accelModifier = accelMod
	self.mudModifier = mudMod
end function

Kart.checkEnemies = function
    if self.worldBounds.overlaps(globals.player2.worldBounds) then
        dx = self.lx - globals.player2.lx
        dy = self.ly - globals.player2.ly
        dist = sqrt(dx*dx + dy*dy)
        speed = 100
        
        // Normalize the distance vector if necessary
        if dist == 0 then
            dx = 1  // Avoid division by zero
            dy = 0
            dist = 1
        end if

        // Ensure that they bump away from each other with a minimum distance
        if dist < speed then
            scaleFactor = (speed - dist) / dist
            dx *= scaleFactor
            dy *= scaleFactor
        end if

        // Calculate weight difference and bounce factors
        totalWeight = (self.weightModifier*(self.lScale/4) + self.defenceTimer) + (globals.player2.weightModifier*(globals.player2.lScale/4) + globals.player2.defenceTimer)
        selfBounceFactor = globals.player2.weightModifier*(globals.player2.lScale/4) + globals.player2.defenceTimer / totalWeight
        enemyBounceFactor = self.weightModifier*(self.lScale/4) + self.defenceTimer / totalWeight

        // Update velocities to push them apart, proportional to weight
        self.vx += dx * speed/dist * selfBounceFactor
        self.vy += dy * speed/dist * selfBounceFactor
        globals.player2.vx -= dx * speed/dist * enemyBounceFactor
        globals.player2.vy -= dy * speed/dist * enemyBounceFactor

		self.onCarHit
		globals.player2.onCarHit
    end if
end function

Kart.checkMud = function
	col = floor(self.x / camera.tileCellSize)
	row = floor(self.y / camera.tileCellSize)
	tile = ground.cell(col, row)
	for tileData in level.mud
		if tileData[0] == tile then return tileData[1]
	end for
	return -1
end function

Kart.checkWater = function
	col = floor(self.x / camera.tileCellSize)
	row = floor(self.y / camera.tileCellSize)
	tile = ground.cell(col, row)
	for tileData in level.water
		if tileData[0] == tile then return tileData[1]
	end for
	return -1
end function

Kart.checkCheckpoints = function

	for c in objects.Coin.instances
		if self.overlaps(c) then c.collect self
	end for

	for c in level.checkpoints
		if self.overlaps(c) then 
			index = level.checkpoints.indexOf(c)
			if index == (self.currentCheckpoint + 1)%level.checkpoints.len then 
				self.currentCheckpoint = index
				self.onCheckpointFound
				if self.currentCheckpoint == 0 then 
					self.currentLap += 1
					self.score += constants.lapScore
				end if
				ui.update self
			end if
		end if
	end for

	if self.currentLap > level.laps then
		self.wins += 1
		self.coins += 10
		self.score += constants.winScore
		ui.winner = self
		ui.levelComplete
	end if
end function

Kart.update = function(dt=0.0167)
	super.update dt
	shrinkRay = findByType(self.currentUpgrades, upgrades.ShrinkRay)
	if shrinkRay.level == 1 then
		self.shootTimer -= dt
		if self.shootTimer <= 0 then
			b = new Shot
			if self isa PlayerKart then b.target = player2
			if self isa EnemyKart then b.target = player
			b.lx = self.lx; b.y = self.ly
			b.rotation = self.rotation
			b.init
			self.shootTimer = self.shootTime
		end if
	else if shrinkRay.level == 2 then
		self.shootTimer -= dt * 0.9
		if self.shootTimer <= 0 then
			for i in range(-25, 25, 25)
				b = new Shot
				if self isa PlayerKart then b.target = player2
				if self isa EnemyKart then b.target = player
				b.lx = self.lx; b.y = self.ly
				b.rotation = self.rotation + i
				b.init
				self.shootTimer = self.shootTime
			end for
		end if
	end if
end function

Kart.forwardInput = function
	return key.axis("Vertical")
end function

Kart.turnInput = function
	return key.axis("Horizontal")
end function

Kart.updateUpgrades = function(opponent)
	if findByType(self.currentUpgrades, upgrades.Juggernaut).level >= 2 then
		if self.worldBounds.overlaps(opponent.worldBounds) then
			if abs(self.bx) + abs(self.by) < 220 then 
				sound.boost.play
				sound.boost.adjust 0.2 * globals.soundVol
			end if
			angle_radians = (self.rotation + 90) % 360 * ((pi * 2) / 360)
			self.bx = cos(angle_radians) * 220
			self.by = sin(angle_radians) * 220
		end if
	end if
	if findByType(self.currentUpgrades, upgrades.Defence).level >= 1 then
		if self.defenceTimer > 0 then self.defenceTimer -= dt
		if self.defenceTimer < 0 then self.defenceTimer = 0
		if self.worldBounds.overlaps(opponent.worldBounds) then self.defenceTimer = self.defenceTime
	end if
end function

Kart.updateMaxSpeed = function(shrinkMod)
	
	inWater = self.checkWater
	if inWater != -1 then
		if self.lScale <= 4 then
			self.currentMaxSpeed = mathUtil.moveTowards(self.currentMaxSpeed, self.mudSpeed * shrinkMod * self.speedModifier*(inWater), 700*self.mudModifier*dt)
			self.tint = "#2222AA44"
		else
			self.currentMaxSpeed = mathUtil.moveTowards(self.currentMaxSpeed, self.maxSpeed*0.85 * shrinkMod * self.speedModifier, 1000*dt)
			self.tint = "#6666FF66"
		end if
	else
		self.tint = "#FFFFFFFF"
    	mudType = self.checkMud
		if mudType != -1 then
			self.currentMaxSpeed = mathUtil.moveTowards(self.currentMaxSpeed, self.mudSpeed * shrinkMod * self.speedModifier*(mudType), 500*self.mudModifier*dt)
    	else
    	    self.currentMaxSpeed = mathUtil.moveTowards(self.currentMaxSpeed, self.maxSpeed * shrinkMod * self.speedModifier, 1000*dt)
		end if
	end if
end function

Kart.getSpeedScaleMod = function
	if findByType(self.currentUpgrades, upgrades.Defence).level >= 2 then
		return 1 + (self.maxSpeed - (self.maxSpeed - currentSpeed))/self.maxSpeed/4
	end if
	return 1
end function

Kart.clampSpeed = function(currentSpeed, shrinkMod)
	if currentSpeed > self.currentMaxSpeed * self.speedModifier * shrinkMod then
		scale = self.currentMaxSpeed * self.speedModifier * shrinkMod / currentSpeed
		self.vx *= scale
		self.vy *= scale
	end if
end function

Kart.emitParticles = function(isPlayer, angle_dif)
	if abs(self.bx) + abs(self.by) > 50 then
		particles.spawnRelativeToParent(
			self,
			particles.BoostParticle,
			mathUtil.randRange(-10, 10),
			-20 + mathUtil.randRange(-10, 10))
	else
		if angle_dif > 45 then
			p = new particles.DriftParticle
			p.lx = self.lx
			p.ly = self.ly
			p.rotation = self.rotation
			p.parent = self
			if isPlayer then
				driftFraction = (self.driftBoost) / self.maxDriftBoost * 255
				p.color = color.rgb(driftFraction, driftFraction/4, driftFraction/4)
			end if
			p.init
		end if
		if self.forwardInput != 0 then
			if self.checkMud == -1 then
				particles.spawnRelativeToParent(
					self,
					particles.DustParticle,
					mathUtil.randRange(-5, 5),
					-30 + mathUtil.randRange(-10, 10))
			else 
				particles.spawnRelativeToParent(
					self,
					particles.MudParticle,
					mathUtil.randRange(-5, 5),
					-20 + mathUtil.randRange(-10, 10))
			end if
		end if
	end if
end function

Kart.calculateVelocityAngle = function
	angle_deg = 0
	if self.vx == 0 and self.vy == 0 then
		angle_deg = 0 // undefined
	else if self.vx == 0 then
		if self.vy > 0 then
			angle_deg = 90 // Positive y-axis
		else
			angle_deg = 270 // Negative y-axis
		end if
	else
		angle_rad = atan(self.vy / self.vx)

		if self.vx > 0 then
			angle_deg = angle_rad * (180 / pi)
			if self.vy < 0 then
				angle_deg += 360 // Ensure the angle is positive
			end if
		else
			angle_deg = angle_rad * (180 / pi) + 180 // Second or third quadrant
		end if
	end if
	return angle_deg
end function

Kart.tryAccelerate = function(tdx, tdy)
	self.boostTime = 0
	// Accelerate or decelerate based on user input
	accelInput = self.forwardInput
	mudAccel = 1
	col = floor(self.lx / camera.tileCellSize)
	row = floor(self.ly / camera.tileCellSize)
	tile = ground.cell(col, row)
	if tile != null then mudAccel = 0.7
	if accelInput != 0 then
		accelFactor = self.accel * self.accelModifier * mudAccel * accelInput * dt
		self.vx += tdx * accelFactor
		self.vy += tdy * accelFactor
	else
		self.vx = mathUtil.moveTowards(self.vx, 0, self.decel * dt)
		self.vy = mathUtil.moveTowards(self.vy, 0, self.decel * dt)
	end if
end function

Kart.onCheckpointFound = function
end function

Kart.onCarHit = function
end function

PlayerKart = new Kart
PlayerKart.lx = 480
PlayerKart.ly = 320
PlayerKart.sprites = []
PlayerKart.maxDriftBoost = 400
PlayerKart.driftBoost = 0
PlayerKart.currentUpgrades = []
PlayerKart.losses = 0
PlayerKart.playerNum = 0
PlayerKart.inputs = null

PlayerKart.init = function(playerTwo)
    super.init
	self.playerNum = playerTwo
end function

PlayerKart.forwardInput = function
	return self.inputs.vertical
end function

PlayerKart.turnInput = function
	return self.inputs.horizontal
end function

PlayerKart.update = function(dt = 0.0167)

	shrinkMod = 1.0 - (self.shrinkTimer / self.shrinkTime) * (1.0 - 0.6)

	spdSclMod = self.getSpeedScaleMod
	self.shrinkTimer -= dt
	if self.shrinkTimer < 0 then self.shrinkTimer = 0

	self.updateUpgrades globals.player2

	// Calculate direction vector based on angle
	angle_radians = self.angle_degrees * ((pi * 2) / 360)

	tdx = sin(angle_radians)
	tdy = cos(angle_radians)

	if key.pressed("left shift") and self.forwardInput >= 1 then

		currentSpeed = sqrt(self.vx * self.vx + self.vy * self.vy)

		accelFactor = self.driftAccel * self.accelModifier * dt
		self.vx += tdx * accelFactor
		self.vy += tdy * accelFactor
	else
		self.tryAccelerate tdx, tdy
	end if

	currentSpeed = sqrt(self.vx * self.vx + self.vy * self.vy)

	self.updateMaxSpeed shrinkMod
	self.clampSpeed currentSpeed, shrinkMod

	turnSpeed = self.turnSpeed
	if key.pressed("left shift") then turnSpeed *= 0.8
	// Calculate turn influence based on current speed
	turnInfluence = self.turnInput * mathUtil.clamp(currentSpeed / (self.currentMaxSpeed * self.speedModifier * shrinkMod) * turnSpeed, -turnSpeed, turnSpeed) * dt

	self.lScale = 4 * self.scaleModifier * spdSclMod * shrinkMod + self.defenceTimer
	if key.pressed("left shift") then
		driftUpgrade = findByType(self.currentUpgrades, upgrades.Drift)
		if driftUpgrade != null then
			if driftUpgrade.level == 1 then
				self.driftBoost += abs(turnInfluence) * 2.5
				if self.driftBoost > self.maxDriftBoost*0.9 then self.driftBoost = self.maxDriftBoost*0.9
			else if driftUpgrade.level == 2 then
				self.driftBoost += abs(turnInfluence) * 3
				if self.driftBoost > self.maxDriftBoost then self.driftBoost = self.maxDriftBoost
				self.lScale = 4 * self.scaleModifier * spdSclMod * shrinkMod + (self.driftBoost/self.maxDriftBoost)
			end if
		end if
	else if self.driftBoost != 0 then
		if abs(self.bx) + abs(self.by) < 220 then 
			sound.boost.play
			sound.boost.adjust 0.2 * globals.soundVol
		end if
		angle_radians = (self.rotation + 90) % 360 * ((pi * 2) / 360)
		self.bx = cos(angle_radians) * self.driftBoost
		self.by = sin(angle_radians) * self.driftBoost
		self.driftBoost = 0
	end if
	self.angle_degrees += turnInfluence

	// Update position
	self.lx += (self.vx + self.bx) * dt
	self.ly += (self.vy + self.by) * dt

	// Ensure the angle is within 0 to 360 degrees
	self.angle_degrees %= 360

	// Update rotation for rendering
	self.rotation = -self.angle_degrees

	self.bx = mathUtil.moveTowards(self.bx, 0, self.boostDecel * dt)
	self.by = mathUtil.moveTowards(self.by, 0, self.boostDecel * dt)

	// Check for wall collisions
	self.checkWalls
	self.checkCheckpoints

	angle_deg = self.calculateVelocityAngle

	// Calculate angle difference
	target_angle = (180 - (angle_deg + 90) % 360) % 360
	angle_dif = abs(self.angle_degrees - target_angle) % 360

	// Ensure angle_dif is within 0-180 degrees
	if angle_dif > 180 then
		angle_dif = 360 - angle_dif
	end if

	if self.vx + self.vy != 0 then
		sound.skid.adjust mathUtil.clamp(angle_dif / 180, 0, 0.7) * globals.soundVol
	else
		sound.skid.adjust 0
	end if

	self.emitParticles true, angle_dif
	super.update dt
	self.checkEnemies
end function

EnemyKart = new Kart
EnemyKart.pathPoint = null
EnemyKart.stuckPathPoint = null
EnemyKart.lx = 480
EnemyKart.ly = 320
EnemyKart.maxSpeed = 420
EnemyKart.sprites = []
EnemyKart.images = []
EnemyKart.currentUpgrades = []
EnemyKart.playerNum = 0
EnemyKart.driftBoost = 0
EnemyKart.maxDriftBoost = 0

EnemyKart.init = function(playerTwo)
    super.init
    self.pathPoint = pathUtil.PathPoint.make(globals.path, 0)
	self.playerNum = playerTwo
end function

EnemyKart.reset = function(x, y)
	super.reset x, y
	player2.pathPoint = pathUtil.PathPoint.make(globals.path, 0)
end function

EnemyKart.getStuckPath = function
	if level.blocksWalking(self.x, self.y) then return

	selfPos = {"x": round(self.lx/camera.tileCellSize), "y": round(self.ly/camera.tileCellSize)}
	targetPos = {"x": floor(self.pathPoint.position[0]/camera.tileCellSize+camera.tileCellSize/2), "y": floor(self.pathPoint.position[1]/camera.tileCellSize+camera.tileCellSize/2)}

	path = pathfinding.find(selfPos, targetPos)
	for p in path
		p[0] *= 64; p[1] *= 64
	end for
	self.stuckPathPoint = pathUtil.PathPoint.nearPoint(path, [self.lx, self.ly])
	self.pathPoint.updatePosition
end function

EnemyKart.onCheckpointFound = function
	//self.getPath
end function

EnemyKart.onCarHit = function
	//self.getPath
end function

moveTowardsAngle = function(angle, target, value)
    // Normalize angles to the range [0, 360)
    angle = (angle + 360) % 360
    target = (target + 360) % 360
    // Calculate the difference between the target and current angle
    delta = (target - angle + 360) % 360
    // Determine the shortest direction to move
    if delta > 180 then
        // Move counterclockwise
        delta -= 360
    end if
    // Clamp the movement to the maximum allowed value
    if abs(delta) <= value then
        return target  // If within the move range, return the target
    end if
    return (angle + sign(delta) * value + 360) % 360
end function

EnemyKart.update = function(dt = 0.0167)

	shrinkMod = 1.0 - (self.shrinkTimer / self.shrinkTime) * (1.0 - 0.6)

	self.shrinkTimer -= dt
	if self.shrinkTimer < 0 then self.shrinkTimer = 0

	if findByType(self.currentUpgrades, upgrades.Juggernaut).level >= 2 then
		if self.worldBounds.overlaps(globals.player.worldBounds) then
			if abs(self.bx) + abs(self.by) < 220 then 
				sound.boost.play
				sound.boost.adjust 0.2 * globals.soundVol
			end if
			angle_radians = (self.rotation + 90) % 360 * ((pi * 2) / 360)
			self.bx = cos(angle_radians) * 220
			self.by = sin(angle_radians) * 220
		end if
	end if
	if findByType(self.currentUpgrades, upgrades.Defence).level >= 1 then
		if self.defenceTimer > 0 then self.defenceTimer -= dt
		if self.defenceTimer < 0 then self.defenceTimer = 0
		if self.worldBounds.overlaps(globals.player.worldBounds) then self.defenceTimer = self.defenceTime
	end if

	self.lScale = 4 * self.scaleModifier* shrinkMod
	// Calculate direction vector based on angle
	angle_radians = self.angle_degrees * ((pi * 2) / 360)
    
	tdx = sin(angle_radians)
	tdy = cos(angle_radians)

	self.boostTime = 0
	mudAccel = 1
	col = floor(self.lx / camera.tileCellSize)
	row = floor(self.ly / camera.tileCellSize)
	tile = ground.cell(col, row)
	if tile != null then mudAccel = 0.7
	accelFactor = self.accel * mudAccel * self.accelModifier * dt
	self.vx += tdx * accelFactor
	self.vy += tdy * accelFactor

	currentSpeed = sqrt(self.vx * self.vx + self.vy * self.vy)

    self.updateMaxSpeed shrinkMod
	self.clampSpeed currentSpeed, shrinkMod

	if findByType(self.currentUpgrades, upgrades.Defence).level >= 2 then
		spdSclMod = 1 + (self.maxSpeed - (self.maxSpeed - currentSpeed))/self.maxSpeed/4
	end if

	turnSpeed = self.turnSpeed
	// Calculate turn influence based on current speed
	targetAngle = atan(self.ly - self.pathPoint.position[1], self.lx - self.pathPoint.position[0])
	if self.stuckPathPoint != null then targetAngle = atan(self.ly - self.stuckPathPoint.position[1], self.lx - self.stuckPathPoint.position[0])
    dir = (targetAngle*180/pi+90) 
	self.angle_degrees = moveTowardsAngle(self.angle_degrees, -dir, turnSpeed*dt)

	// Update position
	self.lx += (self.vx + self.bx) * dt
	self.ly += (self.vy + self.by) * dt 

	// Ensure the angle is within 0 to 360 degrees
	self.angle_degrees %= 360

	// Update rotation for rendering
	self.rotation = -self.angle_degrees

	self.bx = mathUtil.moveTowards(self.bx, 0, self.boostDecel * dt)
	self.by = mathUtil.moveTowards(self.by, 0, self.boostDecel * dt)

	// Check for wall collisions
	self.checkWalls
	self.checkCheckpoints

	angle_deg = 0

	if self.vx == 0 and self.vy == 0 then
		angle_deg = 0 // undefined, could return 0 or some error
	else if self.vx == 0 then
		if self.vy > 0 then
			angle_deg = 90 // Positive y-axis
		else
			angle_deg = 270 // Negative y-axis
		end if
	else
		angle_rad = atan(self.vy / self.vx)

		if self.vx > 0 then
			angle_deg = angle_rad * (180 / pi)
			if self.vy < 0 then
				angle_deg += 360 // Ensure the angle is positive
			end if
		else
			angle_deg = angle_rad * (180 / pi) + 180 // Second or third quadrant
		end if
	end if

	// Calculate angle difference
	target_angle = (180 - (angle_deg + 90) % 360) % 360
	angle_dif = abs(self.angle_degrees - target_angle) % 360

	// Ensure angle_dif is within 0-180 degrees
	if angle_dif > 180 then
		angle_dif = 360 - angle_dif
	end if

	if self.vx + self.vy != 0 then
		sound.skid.adjust mathUtil.clamp(angle_dif / 180, 0, 0.7) * globals.soundVol
	else
		sound.skid.adjust 0
	end if

	self.emitParticles false, angle_dif
	super.update dt

	if self.stuckPathPoint == null then
		if mathUtil.distance(self, self.pathPoint.position) < 250 then
		    self.pathPoint.advance currentSpeed*dt
		end if
		if self.pathPoint.isAtEnd or self.pathPoint.curIndex > path.len-1 then
			self.pathPoint.curIndex = 0
		end if
		if level.wallRaycast([self.x, self.y], [self.pathPoint.position[0], self.pathPoint.position[1]]) != null then
			self.getStuckPath
		end if
	else
		if mathUtil.distance(self, self.stuckPathPoint.position) < 250 then
		    self.stuckPathPoint.advance currentSpeed*dt
		end if
		if self.stuckPathPoint.isAtEnd or self.stuckPathPoint.curIndex > path.len-1 then
			self.stuckPathPoint = null
			self.pathPoint = pathUtil.PathPoint.nearPoint(globals.path, [self.lx, self.ly])
			self.pathPoint.advance currentSpeed*dt
		end if
	end if
	self.pathPoint.updatePosition
end function

Shot = new UpdatableSprite
Shot.image = file.loadImage("pics/shot.png")
Shot.target = null
Shot.instances = []
Shot.speed = 700
Shot.lScale = 4
Shot.localBounds = new Bounds
Shot.localBounds.width = Shot.image.width
Shot.localBounds.height = Shot.image.height

Shot.init = function
	super.init
	disp.sprites.push self
	Shot.instances.push self
end function

Shot.die = function
	super.die
	disp.sprites.removeVal self
	Shot.instances.removeVal self
end function

Shot.update = function(dt=0.0167)
if self.isOnScreen == false then self.die
if self.target.worldBounds == null then return
	if self.overlaps(self.target.worldBounds) then
		self.target.shrinkTimer = self.target.shrinkTime
		self.die
	end if
	angle_radians = -self.rotation * ((pi * 2) / 360)
	dx = sin(angle_radians)
	dy = cos(angle_radians)
	self.lx += dx * self.speed * dt
	self.ly += dy * self.speed * dt
end function

clear = function
	for s in Shot.instances
		disp.sprites.removeVal s
		s.suspend
	end for
	Shot.instances = []
end function
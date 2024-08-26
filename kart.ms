import "importUtil"
ensureImport "camera"
ensureImport "particles"
ensureImport "stackedSprite"
ensureImport "mathUtil"
ensureImport "sound"

findByType = function(lst, type)
    for item in lst
        if item isa type then return item
    end for
    return null
end function

Kart = new StackedSprite
Kart.x = 480
Kart.y = 320
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

Kart.checkWalls = function
	if level.blocksWalking(self.x + 12, self.y) then
		if self.checkCrate(self.x + 12, self.y) == true then return
		self.x = floor((self.x + 12) / 64) * 64 - 12
		// if self.angle_degrees > 30 or self.angle_degrees < -30 then self.velocity *= -0.5
		self.vx *= -0.6
		self.bx *= -0.6
		if abs(self.vx) > 70 then 
			sound.bump.play
			sound.bump.adjust 0.2 * globals.soundVol
		end if
	end if
	if level.blocksWalking(self.x - 12, self.y) then
		if self.checkCrate(self.x - 12, self.y) == true then return
		self.x = ceil((self.x - 12) / 64) * 64 + 12
		self.vx *= -0.6
		self.bx *= -0.6
		if abs(self.vx) > 70 then 
			sound.bump.play
			sound.bump.adjust 0.2 * globals.soundVol
		end if
	end if
	if level.blocksWalking(self.x, self.y + 12) then
		if self.checkCrate(self.x, self.y + 12) == true then return
		self.y = floor((self.y + 12) / 64) * 64 - 12
		self.vy *= -0.6
		self.by *= -0.6
		if abs(self.vy) > 70 then 
			sound.bump.play
			sound.bump.adjust 0.2 * globals.soundVol
		end if
	end if
	if level.blocksWalking(self.x, self.y - 12) then
		if self.checkCrate(self.x, self.y - 12) == true then return
		self.y = ceil((self.y - 12) / 64) * 64 + 12
		self.vy *= -0.6
		self.by *= -0.6
		if abs(self.vy) > 70 then 
			sound.bump.play
			sound.bump.adjust 0.2 * globals.soundVol
		end if
	end if
	if self.x < 0 then
        self.x = 0
        self.vx *= -0.6
        self.bx *= -0.6
        if abs(self.vx) > 70 then 
			sound.bump.play
			sound.bump.adjust 0.2 * globals.soundVol
		end if
    end if
	if self.y < 0 then
        self.y = 0
        self.vy *= -0.6
        self.by *= -0.6
        if abs(self.vy) > 70 then 
			sound.bump.play
			sound.bump.adjust 0.2 * globals.soundVol
		end if
    end if
	if self.x > ground.extent[0] * 64 then 
		self.x = ground.extent[0] * 64
		self.vx *= -0.6
        self.bx *= -0.6
        if abs(self.vx) > 70 then 
			sound.bump.play
			sound.bump.adjust 0.2 * globals.soundVol
		end if
	end if
	if self.y > ground.extent[1] * 64 then 
		self.y = ground.extent[1] * 64
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
	col = floor(x / 64)
	row = floor(y / 64)
	tile = walls.cell(col, row)
	if tile == 45 then
		if self.scale >= 5 then
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
    if self.worldBounds.overlaps(globals.enemy.worldBounds) then
        dx = self.x - globals.enemy.x
        dy = self.y - globals.enemy.y
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
        totalWeight = (self.weightModifier*(self.scale/4) + self.defenceTimer) + (globals.enemy.weightModifier*(globals.enemy.scale/4) + globals.enemy.defenceTimer)
        selfBounceFactor = globals.enemy.weightModifier*(globals.enemy.scale/4) + globals.enemy.defenceTimer / totalWeight
        enemyBounceFactor = self.weightModifier*(self.scale/4) + self.defenceTimer / totalWeight

        // Update velocities to push them apart, proportional to weight
        self.vx += dx * speed/dist * selfBounceFactor
        self.vy += dy * speed/dist * selfBounceFactor
        globals.enemy.vx -= dx * speed/dist * enemyBounceFactor
        globals.enemy.vy -= dy * speed/dist * enemyBounceFactor
    end if
end function

Kart.checkMud = function
	col = floor(self.x / 64)
	row = floor(self.y / 64)
	tile = ground.cell(col, row)
	if level.mud.indexOf(tile) != null then return level.mud.indexOf(tile)
	return -1
end function

Kart.checkWater = function
	col = floor(self.x / 64)
	row = floor(self.y / 64)
	tile = ground.cell(col, row)
	if level.water.indexOf(tile) != null then return level.water.indexOf(tile)
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
				if self.currentCheckpoint == 0 then 
					self.currentLap += 1
					self.score += 200
				end if
				ui.update
			end if
		end if
	end for

	if self.currentLap > level.laps then
		self.wins += 1
		self.coins += 10
		self.score += 1000
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
			if self isa PlayerKart then b.target = enemy
			if self isa EnemyKart then b.target = player
			b.x = self.x; b.y = self.y
			b.rotation = self.rotation
			b.init
			self.shootTimer = self.shootTime
		end if
	else if shrinkRay.level == 2 then
		self.shootTimer -= dt * 0.9
		if self.shootTimer <= 0 then
			for i in range(-15, 15, 15)
				b = new Shot
				if self isa PlayerKart then b.target = enemy
				if self isa EnemyKart then b.target = player
				b.x = self.x; b.y = self.y
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
		if self.scale >= 3.9 then
			self.currentMaxSpeed = mathUtil.moveTowards(self.currentMaxSpeed, self.mudSpeed * shrinkMod * self.speedModifier/(inWater+1), 700*self.mudModifier*(inWater+1)*dt)
			self.tint = "#2222AA44"
		else
			self.currentMaxSpeed = mathUtil.moveTowards(self.currentMaxSpeed, self.maxSpeed*0.85 * shrinkMod * self.speedModifier, 1000*dt)
			self.tint = "#6666FF66"
		end if
	else
		self.tint = "#FFFFFFFF"
    	mudType = self.checkMud
		if mudType != -1 then
			self.currentMaxSpeed = mathUtil.moveTowards(self.currentMaxSpeed, self.mudSpeed * shrinkMod * self.speedModifier/(mudType+1), 500*self.mudModifier*(mudType+1)*dt)
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
			p.x = self.x
			p.y = self.y
			p.rotation = self.rotation
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

PlayerKart = new Kart
PlayerKart.x = 480
PlayerKart.y = 320
PlayerKart.sprites = []
PlayerKart.maxDriftBoost = 400
PlayerKart.driftBoost = 0
PlayerKart.currentUpgrades = []

PlayerKart.init = function
    super.init
end function

PlayerKart.update = function(dt = 0.0167)

	shrinkMod = 1.0 - (self.shrinkTimer / self.shrinkTime) * (1.0 - 0.6)

	spdSclMod = self.getSpeedScaleMod
	self.shrinkTimer -= dt
	if self.shrinkTimer < 0 then self.shrinkTimer = 0

	self.updateUpgrades globals.enemy

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
		self.boostTime = 0
		// Accelerate or decelerate based on user input
		accelInput = self.forwardInput
		mudAccel = 1
		col = floor(self.x / 64)
		row = floor(self.y / 64)
		tile = ground.cell(col, row)
		if tile != null then mudAccel = 0.5
		if accelInput != 0 then
			accelFactor = self.accel * self.accelModifier * mudAccel * accelInput * dt
			self.vx += tdx * accelFactor
			self.vy += tdy * accelFactor
		else
			self.vx = mathUtil.moveTowards(self.vx, 0, self.decel * dt)
			self.vy = mathUtil.moveTowards(self.vy, 0, self.decel * dt)
		end if
	end if

	currentSpeed = sqrt(self.vx * self.vx + self.vy * self.vy)

	self.updateMaxSpeed shrinkMod
	self.clampSpeed currentSpeed, shrinkMod

	turnSpeed = self.turnSpeed
	if key.pressed("left shift") then turnSpeed *= 0.8
	// Calculate turn influence based on current speed
	turnInfluence = self.turnInput * mathUtil.clamp(currentSpeed / (self.currentMaxSpeed * self.speedModifier * shrinkMod) * turnSpeed, -turnSpeed, turnSpeed) * dt

	self.scale = 4 * self.scaleModifier * spdSclMod * shrinkMod + self.defenceTimer
	if key.pressed("left shift") then
		driftUpgrade = findByType(self.currentUpgrades, upgrades.Drift)
		if driftUpgrade != null then
			if driftUpgrade.level == 1 then
				self.driftBoost += abs(turnInfluence) * 2.5
				if self.driftBoost > self.maxDriftBoost*0.9 then self.driftBoost = self.maxDriftBoost*0.9
			else if driftUpgrade.level == 2 then
				self.driftBoost += abs(turnInfluence) * 3
				if self.driftBoost > self.maxDriftBoost then self.driftBoost = self.maxDriftBoost
				self.scale = 4 * self.scaleModifier * spdSclMod * shrinkMod + (self.driftBoost/self.maxDriftBoost)
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
	self.x += (self.vx + self.bx) * dt
	self.y += (self.vy + self.by) * dt

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
EnemyKart.x = 480
EnemyKart.y = 320
EnemyKart.maxSpeed = 420
EnemyKart.sprites = []
EnemyKart.images = []
EnemyKart.currentUpgrades = []

EnemyKart.init = function
    super.init
    self.pathPoint = pathUtil.PathPoint.nearPoint(globals.path, [self.x, self.y])
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

	self.scale = 4 * self.scaleModifier* shrinkMod
	// Calculate direction vector based on angle
	angle_radians = self.angle_degrees * ((pi * 2) / 360)
    
	tdx = sin(angle_radians)
	tdy = cos(angle_radians)

	self.boostTime = 0
	mudAccel = 1
	col = floor(self.x / 64)
	row = floor(self.y / 64)
	tile = ground.cell(col, row)
	if tile != null then mudAccel = 0.5
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
    dir = ((atan(self.y - self.pathPoint.position[1], self.x - self.pathPoint.position[0]))*180/pi+90) 
	self.angle_degrees = moveTowardsAngle(self.angle_degrees, -dir, turnSpeed*dt)

	// Update position
	self.x += (self.vx + self.bx) * dt
	self.y += (self.vy + self.by) * dt

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
	if mathUtil.distance(self, self.pathPoint.position) < 250 then
	    self.pathPoint.advance(currentSpeed * dt)
	end if
	if self.pathPoint.isAtEnd then
	    self.pathPoint.curIndex = 0
	end if
	self.pathPoint.updatePosition
end function

Shot = new UpdatableSprite
Shot.image = file.loadImage("pics/shot.png")
Shot.target = null
Shot.instances = []
Shot.speed = 700
Shot.scale = 4
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
	self.x += dx * self.speed * dt
	self.y += dy * self.speed * dt
end function

clear = function
	for s in Shot.instances
		disp.sprites.removeVal s
		s.suspend
	end for
	Shot.instances = []
end function
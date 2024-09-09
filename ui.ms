
winner = null

update = function(kart)
	if kart == globals.player then
	    gfx.fillRect 0, 640/2, 960/2, 640/2, color.clear
	    txt = "Lap: " + player.currentLap + " / " + level.laps
	    gfx.print txt, 10, 600, color.white, "large"
	    gfx.line 0, 600, txt.len*20+20, 600, color.white, 5
	    txt = "Coins: " + player.coins
	    gfx.print txt, 10, 560, color.white, "large"
	    gfx.line 0, 560, txt.len*20+20, 560, color.white, 5
		score = "000000" + player.score
		txt = "Score: " + score[-6:]
	    gfx.print txt, 10, 520, color.white, "large"
	    gfx.line 0, 520, txt.len*20+20, 520, color.white, 5
	else
		gfx.fillRect 960/2, 640/2, 960/2, 640/2, color.clear
		txt = "Lap: " + player2.currentLap + " / " + level.laps
	    gfx.print txt, 950-txt.len*20, 600, color.red, "large"
	    gfx.line 960, 600, 960-txt.len*20-20, 600, color.red, 5
	    txt = "Coins: " + player2.coins
	    gfx.print txt, 950-txt.len*20, 560, color.red, "large"
	    gfx.line 960, 560, 960-txt.len*20-20, 560, color.red, 5
		score = "000000" + player2.score
		txt = "Score: " + score[-6:]
	    gfx.print txt, 960-txt.len*20-10, 520, color.red, "large"
	    gfx.line 960, 520, 960-txt.len*20-10, 520, color.red, 5
	end if
	txt = "Round: " + level.race + " / 10" 
	gfx.print txt, 960/2-txt.len*10, 600, color.white, "large"
	gfx.line 960/2-txt.len*10, 600, 960/2+txt.len*10, 600, color.white, 5
end function

setEnemyUpgrade = function
	possibleUpgrades = upgrades.getUpgrades(player2)

	for i in range(possibleUpgrades.len-1, 0, -1)  // Loop through itemList in reverse
	    if possibleUpgrades[i].prices[possibleUpgrades[i].level] > player2.coins then possibleUpgrades.remove(i)
	end for

	if possibleUpgrades == [] then return

	chosenUpgrade = possibleUpgrades[possibleUpgrades.len*rnd]

	for u in player2.currentUpgrades
		if u.name == chosenUpgrade.name then
			player2.coins -= chosenUpgrade.prices[chosenUpgrade.level]
			player2.score += constants.upgradeScore
			u.level += 1
			return
		end if
	end for
end function

playLossAnimation = function

	player.score += constants.lossScore

	medals = []

	// Add the correct medals depending on the player losses

	bronze = new Sprite
	bronze.image = images.bronzeMedal
	bronze.x = 960*(3/8) + disp.scrollX; bronze.y = 640/2 + disp.scrollY; bronze.scale = 4
	disp.sprites.push bronze
	medals.push bronze

	if player.losses < 2 then
		silver = new Sprite
		silver.image = images.silverMedal
		silver.x = 960*(4/8) + disp.scrollX; silver.y = 640/2 + disp.scrollY; silver.scale = 4
		disp.sprites.push silver
		medals.push silver
	end if

	if player.losses == 0 then
		gold = new Sprite
		gold.image = images.goldMedal
		gold.x = 960*(5/8) + disp.scrollX; gold.y = 640/2 + disp.scrollY; gold.scale = 4
		disp.sprites.push gold
		medals.push gold
	end if

	// Fade UI in

	for a in range(0, 255, 5)
		for m in medals
			m.tint = color.rgba(255, 255, 255, a)
		end for
		yield
		txt = "Losses: " + player.losses + " / 3"
		gfx.print txt, 960/2 - txt.len*10, 400, color.rgba(255, 255, 255, a), "large"
	end for

	chosenMedal = medals[-1]

	animStart = time
	startX = chosenMedal.x 
	startY = chosenMedal.y
	sound.suspence.play
	sound.suspence.adjust 0

	// Shake medal and play suspence sound for 2 seconds

	while time < animStart + 2
		chosenMedal.x = startX + (mathUtil.randRange(-10, 10) * (time - animStart))
		chosenMedal.y = startY + (mathUtil.randRange(-10, 10) * (time - animStart))
		sound.suspence.adjust (time - animStart) / 4.5
	end while

	disp.sprites.removeVal chosenMedal
	sound.suspence.stop
	sound.crack.play
	player.losses += 1
	gfx.fillRect 0, 0, 960, 640, color.clear
	txt = "Losses: " + player.losses + " / 3"
	gfx.print txt, 960/2 - txt.len*10, 400, color.rgba(255, 255, 255, 255), "large"

	wait 0.5

	// Fade ui out

	for a in range(255, 0, -5)
		for m in medals
			m.tint = color.rgba(255, 255, 255, a)
		end for
		txt = "Losses: " + player.losses + " / 3"
		gfx.print txt, 960/2 - txt.len*10, 400, color.rgba(255, 255, 255, a), "large"
		yield
	end for
	gfx.fillRect 0, 0, 960, 640, color.clear

	for m in medals
		disp.sprites.removeVal m
	end for

	playerLost = false
	if player.losses >= 3 then endGame
end function

levelComplete = function

	particles.clear
	lastTime = time
	while player.vx + player.vy + player2.vy + player2.vx != 0
		yield
		dt=time-lastTime
		lastTime = time

		player.vx = mathUtil.moveTowards(player.vx, 0, 400 * dt)
		player2.vx = mathUtil.moveTowards(player2.vx, 0, 400 * dt)
		player.vy = mathUtil.moveTowards(player.vy, 0, 400 * dt)
		player2.vy = mathUtil.moveTowards(player2.vy, 0, 400 * dt)
		player.lx += player.vx * dt; player.ly += player.vy * dt
		player2.lx += player2.vx * dt; player2.ly += player2.vy * dt

		globals.updateSpritePositions
		player.updateSprites; player2.updateSprites
		camera.update
	end while

	wait 0.5

	gfx.clear
	sound.skid.adjust 0
	bg = new Sprite
    bg.image = images.woodPanel
    bg.y = -320 + disp.scrollY
    bg.x = 960/2 + disp.scrollX
    bg.scale = 4
    disp.sprites.push bg
    for y in range(-320, 320, 5)
        bg.y = y  + disp.scrollY
        yield
    end for
	player.x = 0; player.y = 0
	camera.update
	bg.y = 320
	bg.x = 960/2

	if winner != player then playLossAnimation

	if file.exists(level.levelPath + "1-"  + (level.race+1) + ".dat") then
		chooseUpgrades
	else
		endGame
	end if
end function

chooseUpgrades = function
	txt = "Level Complete! Choose an upgrade."
	gfx.print txt, 960/2 - txt.len*20/2, 580, color.white, "large"
	txt = "Player wins: " + player.wins
	gfx.print txt, 10, 10+90, color.white, "large"
	txt = "Player coins: " + player.coins
	gfx.print txt, 10, 10+60, color.yellow, "large"
	txt = "Player 2 wins: " + player2.wins
	gfx.print txt, 10, 10+30, color.white, "large"
	txt = "Player 2 coins: " + player2.coins
	gfx.print txt, 10, 10, color.yellow, "large"
	if winner == player then
		txt = "Player gets 10 coins for winning!"
		gfx.print txt, 960/2 - txt.len*11/2, 560, color.yellow, "medium"
	else if winner == player2 then
		txt = "Player 2 gets 10 coins for winning!"
		gfx.print txt, 960/2 - txt.len*11/2, 560, color.yellow, "medium"
	end if
	
	next = new Button
	next.x = 880; next.y = 100
	next.text = "NEXT"
	next.init
	objects.clear
	camera.update
	upgradeButtons = []
	possibleUpgrades = upgrades.getUpgrades(player)
	for i in range(0, 2)
		b = new UpgradeButton 
		nextUpgrade = possibleUpgrades[possibleUpgrades.len*rnd]
		b.upgrade = nextUpgrade
		possibleUpgrades.removeVal nextUpgrade
		b.x = 170 + 310 * i
		b.y = 350
		if b.upgrade == null then continue
		b.text = b.upgrade.descriptions[nextUpgrade.level]
		if nextUpgrade.icons != [] then b.bigImage = nextUpgrade.icons[nextUpgrade.level]
		b.init
		upgradeButtons.push b
	end for
	chosenUpgrade = null
	while true  // (press Control-C to exit)
	    yield
	    // The mouse button is down.  Check each of our buttons, 
	    // and do whatever they should do if clicked.
	    if next.isClicked then
	        Button.clear
			if chosenUpgrade != null then 
				for upgrade in player.currentUpgrades
					if upgrade.name == chosenUpgrade.name then
						player.coins -= chosenUpgrade.prices[chosenUpgrade.level]
						player.score += constants.upgradeScore
						upgrade.level += 1
					end if
				end for
			end if
			setEnemyUpgrade
			disp.sprites = [player, player2]
			gfx.clear
			level.race += 1
			level.setup
			globals.lastTime = time
			return
	    end if
		for u in upgradeButtons
			if u.isClicked then 
				chosenUpgrade = u.upgrade
			end if
		end for
	end while
end function

endGame = function

	if highscore.isHighScore(player.score) then
		name = "BRU"//highscore.postNewScoreDialog
		highscore.addScore player.score, name
		highscore.saveScores
	end if

	txt = "Thank you for playing!"
	gfx.print txt, 960/2 - txt.len*20/2, 580, color.white, "large"
	menu = new ui.Button
	menu.x = 960/2; menu.y = 100
	menu.text = "RESTART"
	menu.init
	trophy = new Sprite
	trophy.image = images.trophyImg
	trophy.x = 960/2
	trophy.y = 440
	trophy.scale = 4

	if player.wins >= 5 then
		txt = "You got " + player.wins + " wins!"
		gfx.print txt, 960/2 - txt.len*10, 260, color.white, "large"
		txt = "And won a "
		if player.wins == 10 then
			trophy.tint = color.aqua
			txt += "PLATINUM Trophy!"
		else if player.wins >= 8 then
			trophy.tint = color.yellow
			txt += "GOLD Trophy!"
		else if player.wins >= 6 then
			trophy.tint = color.silver
			txt += "SILVER Trophy!"
		else if player.wins >= 3 then
			trophy.tint = color.orange
			txt += "BRONZE Trophy!"
		end if
		gfx.print txt, 960/2 - txt.len*10, 230, color.white, "large"
		txt = "And lasted " + level.race + " Rounds."
		gfx.print txt, 960/2 - txt.len*10, 200, color.white, "large"
		txt = "Play again?"
		gfx.print txt, 960/2 - txt.len*10, 170, color.white, "large"
		disp.sprites.push trophy
	else
		txt = "You got " + player.wins + " wins..."
		gfx.print txt, 960/2 - txt.len*10, 260, color.white, "large"
		txt = "And lasted " + level.race + " Rounds."
		gfx.print txt, 960/2 - txt.len*10, 230, color.white, "large"
		txt = "Try again?"
		gfx.print txt, 960/2 - txt.len*10, 200, color.white, "large"
	end if
	objects.clear
	camera.update(0, 0)
	while true  // (press Control-C to exit)
	    yield
	    // The mouse button is down.  Check each of our buttons, 
	    // and do whatever they should do if clicked.
		if menu.isClicked then
			reset; run "main"
			return
	    end if
	end while
end function

Button = new UpdatableSprite
Button.bigImage = file.loadImage("pics/bigButton.png")
Button.regImage = file.loadImage("pics/button.png")
Button.smallImage = file.loadImage("pics/miniButton.png")
Button.size = 1
Button.color = color.white
Button.pressedColor = color.silver
Button.disabledColor = color.gray
Button.wasDown = false
Button.text = "START"
Button.instances = []
Button.disabled = false
Button.scale = 4

Button.init = function
    super.init
    if self.size == 0 then 
        self.image = self.smallImage
    else if self.size == 1 then 
		self.image = self.regImage
	else
        self.image = self.bigImage
    end if
    disp.sprites.push self

	self.printText
	
    Button.instances.push self
end function

Button.printText = function
	gfx.fillRect self.x-self.image.width*self.scale/2, self.y-self.image.height*self.scale/2, self.image.width*self.scale, self.image.height*self.scale, color.clear
	gfx.print self.text, self.x-self.text.len*10, self.y-32/2+5, color.black, "large"
end function

Button.die = function
    super.die
    disp.sprites.removeVal self
    gfx.fillRect self.x-self.text.len*10+2, self.y-32/2+5, self.text.len*20, 20+24, color.clear
end function

Button.clear = function
    for b in Button.instances; b.die; end for
    Button.instances = []
end function

Button.isClicked = function

	if self.disabled == true then
		self.tint = self.disabledColor
		return
	end if

    isDown = mouse.button
	// Ensure the self has a bounds.
	if not self.localBounds then
		self.localBounds = new Bounds
		self.localBounds.width = self.image.width
		self.localBounds.height = self.image.height
	end if
	if self.contains(mouse) then
		self.tint = self.pressedColor
        if self.wasDown and not isDown then 
            sound.blip.play
			self.wasDown = isDown
            return true
        end if
	else
		self.tint = self.color
	end if
	// Return whether the mouse was released within bounds.
    self.wasDown = isDown
	return false
end function

Button.onClick = function
end function

UpgradeButton = new Button
UpgradeButton.bigImage = file.loadImage("pics/abilities/paper.png")
UpgradeButton.upgrade = null
UpgradeButton.size = 3
UpgradeButton.highlighted = false
UpgradeButton.instances = []

lastIndexOf = function(s, char)
    for i in range(s.len-1, 0, -1)
        if s[i] == char then return i
    end for
    return null  // Return null if the character is not found
end function

UpgradeButton.init = function
	super.init
	UpgradeButton.instances.push self
end function

UpgradeButton.die = function
	super.die
	UpgradeButton.instances.removeVal self
end function 	

UpgradeButton.printText = function
	maxLength = 18
	chunks = []

	while self.text.len > 0
		// Find the largest substring that fits within maxLength
		if self.text.len <= maxLength then
			chunk = self.text  // If the remaining text is short enough, take it all
			self.text = ""  // Clear the remaining text
		else
			// Look for the last space within the maxLength boundary
			chunk = self.text[:maxLength]
			spaceIndex = lastIndexOf(chunk, " ")
			if spaceIndex == null then
				spaceIndex = maxLength  // No space found, so take the max length
			end if
			
			chunk = self.text[:spaceIndex]  // Take up to the space
			self.text = self.text[spaceIndex+1:]  // Remove the chunk (plus the space) from text
		end if
		
		chunks.push(chunk)  // Add the chunk to the list
	end while

	for i in range(0, chunks.len-1)
		gfx.print chunks[i], self.x-self.image.width*1.6, self.y-32/2+7+24*-i, color.black, "normal"
	end for
	txt = "Price: " + self.upgrade.prices[self.upgrade.level]
	if self.upgrade.prices[self.upgrade.level] > player.coins then 
		txt = "Too Expensive!"
		self.disabled = true
	end if
	gfx.print txt, self.x-self.image.width*1.6, self.y-self.image.height*1.78, color.black, "normal"
	txt = self.upgrade.name
	gfx.print txt, self.x-self.image.width*1.6, self.y+self.image.height*1.73, color.black, "normal"
end function

UpgradeButton.isClicked = function

	if self.disabled == true then
		self.tint = color.gray
		return
	end if

	if self.highlighted == true then
		self.tint = color.orange
		return
	end if

	isDown = mouse.button
	// Ensure the self has a bounds.
	if not self.localBounds then
		self.localBounds = new Bounds
		self.localBounds.width = self.image.width
		self.localBounds.height = self.image.height
	end if
	if self.contains(mouse) then
		self.tint = color.silver
		if self.wasDown and not isDown then 
			sound.blip.play
			for b in UpgradeButton.instances
				if b == self then continue
				b.highlighted = false
			end for
			self.highlighted = true
			return true
		end if
	else
		self.tint = color.white
	end if
	// Return whether the mouse was released within bounds.
	self.wasDown = isDown
	return false
end function

Slider = new updatable.Updatable
Slider.x = 0; Slider.y = 0
Slider.width = 100; Slider.height = 20
Slider.radius = 20
Slider.value = 0.5
Slider.dragging = false
Slider.text = "Slider:"

Slider.draw = function
    gfx.fillRect self.x-self.radius, self.y - self.radius - self.height/2, self.width + self.radius*2, self.height + self.radius*2, color.clear
    // Draw the slider bar
    gfx.fillRect self.x, self.y - self.height/2, self.width, self.height, color.gray
    // Draw the knob
    knobX = self.x + self.value * self.width
    gfx.fillEllipse knobX - self.radius, self.y - self.radius, self.radius * 2, self.radius * 2, color.silver
	// Print text
    gfx.print self.text, self.x-self.text.len*20-self.radius, self.y-14, color.silver, "large"
end function

Slider.updateSlider = function
    mouseX = mouse.x
    // Clamp the mouseX within the slider's bounds
    if mouseX < self.x then mouseX = self.x
    if mouseX > self.x + self.width then mouseX = self.x + self.width
    // Update the value based on the clamped mouseX position
    self.value = (mouseX - self.x) / self.width
end function

Slider.update = function(dt=0.0167)
    // Draw the slider
    self.draw
    // Check for mouse input
    if mouse.button then
        if self.isKnobClicked then self.dragging = true
        if self.dragging then self.updateSlider
    else
        self.dragging = false
    end if
end function

Slider.isKnobClicked = function
    knobX = self.x + self.value * self.width
    dist = (mouse.x - knobX)^2 + (mouse.y - self.y)^2
    return dist <= self.radius^2
end function

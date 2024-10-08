
winner = null

update = function(kart)
	if kart == globals.player1 then
	    gfx.fillRect 0, 640/2, 960/2, 640/2, color.clear
	    txt = "Lap: " + player1.currentLap + " / " + level.laps
	    gfx.print txt, 10, 600, color.white, "large"
	    gfx.line 0, 600, txt.len*20+20, 600, color.white, 5
	    txt = "Coins: " + player1.coins
	    gfx.print txt, 10, 560, color.white, "large"
	    gfx.line 0, 560, txt.len*20+20, 560, color.white, 5
		score = "000000" + player1.score
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

	medals = []

	// Add the correct medals depending on the player losses

	bronze = new Sprite
	bronze.image = images.bronzeMedal
	bronze.x = 960*(3/8) + disp.scrollX; bronze.y = 640/2 + disp.scrollY; bronze.scale = 4
	disp.sprites.push bronze
	medals.push bronze

	if player1.losses < 2 then
		silver = new Sprite
		silver.image = images.silverMedal
		silver.x = 960*(4/8) + disp.scrollX; silver.y = 640/2 + disp.scrollY; silver.scale = 4
		disp.sprites.push silver
		medals.push silver
	end if

	if player1.losses == 0 then
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
		txt = "Losses: " + player1.losses + " / 3"
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
	player1.losses += 1
	gfx.fillRect 0, 0, 960, 640, color.clear
	txt = "Losses: " + player1.losses + " / 3"
	gfx.print txt, 960/2 - txt.len*10, 400, color.rgba(255, 255, 255, 255), "large"

	wait 0.5

	// Fade ui out

	for a in range(255, 0, -5)
		for m in medals
			m.tint = color.rgba(255, 255, 255, a)
		end for
		txt = "Losses: " + player1.losses + " / 3"
		gfx.print txt, 960/2 - txt.len*10, 400, color.rgba(255, 255, 255, a), "large"
		yield
	end for
	gfx.fillRect 0, 0, 960, 640, color.clear

	for m in medals
		disp.sprites.removeVal m
	end for

	playerLost = false
	if player1.losses >= 3 then endGame
end function

levelComplete = function

	Sound.stopAll
	particles.clear
	lastTime = time
	while player1.vx + player1.vy + player2.vy + player2.vx != 0
		yield
		dt=time-lastTime
		lastTime = time

		player1.vx = mathUtil.moveTowards(player1.vx, 0, 400 * dt)
		player2.vx = mathUtil.moveTowards(player2.vx, 0, 400 * dt)
		player1.vy = mathUtil.moveTowards(player1.vy, 0, 400 * dt)
		player2.vy = mathUtil.moveTowards(player2.vy, 0, 400 * dt)
		player1.lx += player1.vx * dt; player1.ly += player1.vy * dt
		player2.lx += player2.vx * dt; player2.ly += player2.vy * dt

		globals.updateSpritePositions
		player1.updateSprites; player2.updateSprites
		camera.update
	end while

	wait 0.5

	gfx.clear
	outer.bg = new Sprite
    bg.image = images.woodPanel
    bg.y = -320 + disp.scrollY
    bg.x = 960/2 + disp.scrollX
    bg.scale = 4
    disp.sprites.push bg
    for y in range(-320, 320, 5)
        bg.y = y  + disp.scrollY
        yield
    end for
	player1.x = 0; player1.y = 0
	camera.reset
	bg.y = 320
	bg.x = 960/2

	if winner != player1 and globals.twoplayer == false then playLossAnimation

	if file.exists(level.levelPath + "1-"  + (level.race+1) + ".dat") then
		if globals.twoplayer == true then
			chooseUpgradeMulti
		else
			chooseUpgradeSingle
		end if
	else
		endGame
	end if
end function

chooseUpgradeSingle = function
	txt = "Level Complete! Choose an upgrade."
	gfx.print txt, 960/2 - txt.len*20/2, 580, color.white, "large"
	txt = "Player wins: " + player1.wins
	gfx.print txt, 10, 10+90, color.white, "large"
	txt = "Player coins: " + player1.coins
	gfx.print txt, 10, 10+60, color.yellow, "large"
	txt = "Player 2 wins: " + player2.wins
	gfx.print txt, 10, 10+30, color.white, "large"
	txt = "Player 2 coins: " + player2.coins
	gfx.print txt, 10, 10, color.yellow, "large"
	if winner == player1 then
		txt = "Player gets 10 coins for winning!"
		gfx.print txt, 960/2 - txt.len*11/2, 560, color.yellow, "medium"
	else if winner == player2 then
		txt = "Player 2 gets 10 coins for winning!"
		gfx.print txt, 960/2 - txt.len*11/2, 560, color.yellow, "medium"
	end if

	next = uiElements.Button.make(880, 100, "NEXT")

	objects.clear
	camera.update
	upgradeButtons = []
	possibleUpgrades = upgrades.getUpgrades(player1)
	for i in range(0, 2)
		nextUpgrade = possibleUpgrades[possibleUpgrades.len*rnd]
		if nextUpgrade == null then continue
		possibleUpgrades.removeVal nextUpgrade
		b = uiElements.UpgradeButton.make(170 + 310 * i, 350, nextUpgrade, player1)
		upgradeButtons.push b
	end for
	chosenUpgrade = null
	while true  // (press Control-C to exit)
	    yield

	    if next.isClicked then
	        uiElements.Button.clear
			if chosenUpgrade != null then 
				for upgrade in player1.currentUpgrades
					if upgrade.name == chosenUpgrade.name then
						player1.coins -= chosenUpgrade.prices[chosenUpgrade.level]
						player1.score += constants.upgradeScore
						upgrade.level += 1
					end if
				end for
			end if
			setEnemyUpgrade
			disp.sprites.removeVal outer.bg
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

chooseUpgradeMulti = function
	gfx.line 960/2, 0, 960/2, 640, color.black, 20
    gfx.line 960/2, 0, 960/2, 640, color.red, 10

	objects.clear
	camera.update

	txt = "Player 1"
    gfx.print txt, 960*(1/4)-txt.len*10, 595, color.white, "large"
    txt = "Player 2"
    gfx.print txt, 960*(3/4)-txt.len*10, 595, color.white, "large"

	txt = "Coins: " + player1.coins
	gfx.print txt, 10, 10, color.yellow, "large"
	txt = "Coins: " + player2.coins
	gfx.print txt, 720, 10, color.yellow, "large"

	possibleUpgrades = {
	    "player1": upgrades.getUpgrades(player1),
	    "player2": upgrades.getUpgrades(player2),
	}
	upgradeButtons = {
	    "player1": [],
	    "player2": [],
	}
	readyButtons = {
		"player1": null,
		"player2": null,
	}

	playerNum = 0
	for p in ["player1", "player2"]
		for i in range(0, 2)
			possible = possibleUpgrades[p]
			buttons = upgradeButtons[p]
			nextUpgrade = possible[possible.len*rnd]
			if nextUpgrade == null then continue
			possible.removeVal nextUpgrade
			b = uiElements.UpgradeButton.make(240 + 960*playerNum/2, 170 + 170 * i, nextUpgrade, globals[p], 1)
			b.channel = playerNum
			buttons.push b
		end for
		ready = uiElements.Button.make(360 + 960*playerNum/4, 45, "READY")
		ready.ready = false
		readyButtons[p] = ready
		playerNum += 1
	end for
	chosenUpgrades = {
	    "player1": null,
	    "player2": null,
	}
	while true  // (press Control-C to exit)
		yield

		ready = true
		for p in ["player1", "player2"]
			button = readyButtons[p]
			if button.isClicked then
            	button.ready = not button.ready
            	if button.ready == true then
            	    button.color = color.lime
            	    button.pressedColor = color.red
            	else
            	    button.color = color.white
            	    button.pressedColor = color.silver
            	end if
			end if
			if button.ready == false then ready = false
        end for

        if ready == true then
			uiElements.Button.clear
			
			for p in ["player1", "player2"]
				chosenUpgrade = chosenUpgrades[p]
				if chosenUpgrade != null then 
					for upgrade in globals[p].currentUpgrades
						if upgrade.name == chosenUpgrade.name then
							globals[p].coins -= chosenUpgrade.prices[chosenUpgrade.level]
							globals[p].score += constants.upgradeScore
							globals[p].currentUpgrades[globals[p].currentUpgrades.indexOf(upgrade)].level += 1
						end if
					end for
				end if
			end for
			disp.sprites.removeVal outer.bg
			gfx.clear
			level.race += 1
			level.setup
			globals.lastTime = time
			return
		end if

		for p in ["player1", "player2"]
			for u in upgradeButtons[p]
				if u.isClicked then 
					chosenUpgrades[p] = u.upgrade
				end if
			end for
		end for
	end while
end function

endGame = function

	highscore.loadScores

	if highscore.isHighScore(player1.score) then
		name = highscore.postNewScoreDialog
		highscore.addScore player1.score, name
		highscore.saveScores
	end if

	highscore.showScores

	txt = "Thank you for playing!"
	gfx.print txt, 960/2 - txt.len*20/2, 580, color.white, "large"
	menu = new uiElements.Button
	menu.x = 960/4; menu.y = 100
	menu.text = "RESTART"
	menu.init
	trophy = new Sprite
	trophy.image = images.trophyImg
	trophy.x = 960/4
	trophy.y = 440
	trophy.scale = 4

	if player1.wins >= 5 then
		txt = "You got " + player1.wins + " wins and"
		gfx.print txt, 960/4 - txt.len*10, 260, color.white, "large"
		txt = "won a "
		if player1.wins == 10 then
			trophy.tint = color.aqua
			txt += "PLATINUM Trophy!"
		else if player1.wins >= 8 then
			trophy.tint = color.yellow
			txt += "GOLD Trophy!"
		else if player1.wins >= 6 then
			trophy.tint = color.silver
			txt += "SILVER Trophy!"
		else if player1.wins >= 3 then
			trophy.tint = color.orange
			txt += "BRONZE Trophy!"
		end if
		gfx.print txt, 960/4 - txt.len*10, 230, color.white, "large"
		txt = "You lasted " + level.race + " Rounds."
		gfx.print txt, 960/4 - txt.len*10, 200, color.white, "large"
		txt = "Play again?"
		gfx.print txt, 960/4 - txt.len*10, 170, color.white, "large"
		disp.sprites.push trophy
	else
		txt = "You got " + player1.wins + " wins..."
		gfx.print txt, 960/4 - txt.len*10, 260, color.white, "large"
		txt = "You lasted " + level.race + " Rounds."
		gfx.print txt, 960/4 - txt.len*10, 230, color.white, "large"
		txt = "Try again?"
		gfx.print txt, 960/4 - txt.len*10, 200, color.white, "large"
	end if
	objects.clear
	camera.reset
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
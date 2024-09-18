
import "importUtil"
ensureImport "textUtil"
ensureImport "chars"

scores = []

addScore = function(points, name)
	sc = {}
	sc.points = points
	sc.name = name
	scores.push sc
	scores.sort "points", 0
	if scores.len > 10 then outer.scores = scores[:10]
end function

resetScores = function
	outer.scores = []
	addScore 18000, "SMC"
	addScore 15850, "AAA"
	addScore 12000, "LEE"
	addScore 9500, "MIN"
	addScore 7500, "FPS"
	addScore 6000, "BOT"
	addScore 5200, "MMO"
	addScore 4500, "CPP"
	addScore 3800, "PYT"
	addScore 2500, "LUA"
end function

scoresFilePath = function
	if not file.exists("/usr/save") then
		file.makedir "/usr/save"
	end if
	return "/usr/save/highscores.dat"
end function

saveScores = function
	lines = []
	for score in scores
		lines.push score.points + ":" + score.name
	end for
	file.writeLines scoresFilePath, lines
end function

loadScores = function
	scoreData = file.readLines(scoresFilePath)
	if scoreData then
		for line in scoreData
			fields = line.split(":", 2)
			if fields.len < 2 then continue
			addScore fields[0].val, fields[1]
		end for
	else
		resetScores
	end if
end function

isHighScore = function(newScore)
	if not scores then return true
	return (newScore > scores[-1].points)
end function

textForRow = function(row)
	s = str(row+1)
	if row < 3 then
		s = s + ["ST", "ND", "RD"][row]
	else
		s = s + "TH"
	end if
	if row < 9 then s = " " + s
	s = s + "   "
	sc = scores[row]
	s = s + ("      " + sc.points)[-7:]
	s = s + " . . . . . " + (sc.name + "   ")[:3]
	return s
end function

showScores = function
	
	top = 20
	//text.color = color.yellow
	//textUtil.printCenteredAt 34, top, "TOP 10 HIGH SCORES"
	//img = file.loadImage("pics/highScoresTitle.png")
	s = "TOP 10 HIGH SCORES"
	gfx.print s, 480 - s.len*10, top*24+10, color.yellow, "large"
	//g.drawImage img, 480 - img.width/2, top*24 + img.height/2
	
	text.color = "#880000"
	textUtil.printCenteredAt 34, top-2, " RANK     SCORE           NAME"
	gfx.print " ____     _____           ____", 19*14-2, (top-2)*24-3, text.color
	gfx.print " ____     _____           ____", 19*14+5, (top-2)*24-3, text.color
	
	text.color = color.aqua
	for i in scores.indexes
		//text.color = colorForRow(i)
		textUtil.printCenteredAt 34, top-4-i, textForRow(i)
	end for
end function

postNewScoreDialog = function(tint="#FFFFFF")
	// Post the "new high score" dialog.  We'll do all our drawing
	// in displays.overlayGfxLayer.

	key.clear // Clear key buffer 

	g = gfx

	dlogX = 480; dlogY = 400
	g.clear
	g.scrollX = (dlogX*g.scale) - dlogX
	g.scrollY = (dlogY*g.scale) - dlogY
	txt = "New High Score!"
	g.print txt, 960/2-txt.len*10, 600, color.white, "large"
	txt = "Press Enter to save."
	g.print txt, 960/2-txt.len*10, 500, color.white, "large"

	g.scrollX = 0; g.scrollY = 0

	drawChar = function(g, c, pos, charColor="#FFFF00")
		x = dlogX - 48 + 36*pos
		g.fillRect x, dlogY-72, 24, 32, color.black
		g.print c, x, dlogY-72, charColor, "large"
	end function
	drawInitials = function(g, cursor=null)
		for pos in [0,1,2]
			if pos == initials.len then
				if cursor == null then cursor = chars.figureStanding
				drawChar g, cursor, pos, color.silver
			else if pos < initials.len then
				drawChar g, initials[pos], pos
			else
				drawChar g, " ", pos
			end if
		end for
	end function
	initials = ""
	while true
		drawInitials g
		waitFrames = 0
		while not key.available
			yield
			waitFrames = waitFrames + 1
			drawInitials g, chars.bullet
		end while
		k = key.get
		if k.code == 8 or k.code == 127 then
			if initials.len then initials = initials[:-1]
		else if k.code == 10 or k.code == 3 then
			initials = (initials + "   ")[:3]
			drawInitials g
			break
		else if k.code > 31 and initials.len < 3 then
			initials = initials + k.upper
		end if
	end while
	while g.scale > 0.1
		g.scale = g.scale - 0.1
		g.scrollX = (dlogX*g.scale) - dlogX
		g.scrollY = (dlogY*g.scale) - dlogY
		yield
	end while	
	g.clear
	g.scale = 1; g.scrollX = 0; g.scrollY = 0
	return initials
end function

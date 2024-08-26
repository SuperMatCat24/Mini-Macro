
import "importUtil"
ensureImport "textUtil"

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
	addScore 10000, "BBJ"
	addScore 9850, "AAA"
	addScore 7660, "LEE"
	addScore 5850, "MS"
	addScore 4500, "FPS"
	addScore 3250, "BOT"
	addScore 2050, "MMO"
	addScore 1550, "CPP"
	addScore 750, "PYT"
	addScore 550, "LUA"
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

postNewScoreDialog = function(tint="#FFFFFF")
	// Post the "new high score" dialog.  We'll do all our drawing
	// in displays.overlayGfxLayer.

	g = gfx

	dlogX = 480; dlogY = 400
	g.clear
	g.scale = 0.1
	g.scrollX = (dlogX*g.scale) - dlogX
	g.scrollY = (dlogY*g.scale) - dlogY
	txt = "New High Score!"
	g.print txt, 960/2-txt.len*10, 600, color.white, "large"
	while g.scale < 1.1
		yield
		g.scale = g.scale + 0.1
		g.scrollX = (dlogX*g.scale) - dlogX
		g.scrollY = (dlogY*g.scale) - dlogY
	end while
	g.scale = 1
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
			if waitFrames < 200 then continue
			if waitFrames % 800 >= 600 then
				if waitFrames % 800 == 600 then drawInitials g, chars.figureAkimbo
			else if waitFrames % 40 == 20 then
				drawInitials g, chars.figureWaitingToeUp
			else if waitFrames % 40 == 0 then
				drawInitials g, chars.figureWaitingToeDown
			end if
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

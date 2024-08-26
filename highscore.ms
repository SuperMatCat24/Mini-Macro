
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

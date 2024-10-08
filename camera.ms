// This module manages the "camera", i.e., the scrolling
// of all displays as needed to keep the player in view.

import "importUtil"
ensureImport "level"

tileCellSize = 64

camBox = {}
camBox.left = 960/2.25
camBox.right = 960/1.75
camBox.bottom = 220
camBox.top = 300

// Scroll as needed to get x,y (in world coordinates)
// to be within camBox (in screen coordinates).
update = function
	if globals.twoplayer == false then
		ground.cellSize = 64
		walls.cellSize = 64
		x = player1.x
		y = player1.y
		sx = ground.scrollX
		sy = ground.scrollY
		if x - sx < camBox.left then
			sx = x - camBox.left
		else if x - sx > camBox.right then
			sx = x - camBox.right
		end if
		if y - sy < camBox.bottom then
			sy = y - camBox.bottom
		else if y - sy > camBox.top then
			sy = y - camBox.top
		end if
		if sx < 0 then
			sx = 0
		else if sx + 960 > ground.extent[0] * 64 then
			sx = ground.extent[0] * 64 - 960
		end if
		if sy < 0 then
			sy = 0
		else if sy + 640 > ground.extent[1] * 64 then
			sy = ground.extent[1] * 64 - 640
		end if
		scrollTo sx, sy
	else
		// Calculate the center point between the players
		centerX = (player1.x + player2.x) / 2 - 960/2
		centerY = (player1.y + player2.y) / 2 - 640/2

		// Calculate the distance between the players
		distanceX = abs(player2.x - player1.x)
		distanceY = abs(player2.y - player1.y)
		distance = (distanceX + distanceY) / 2

		// Calculate the scaling factors to fit both players on screen
		scaleX = 960 / (distanceX) // Adding 64 for a bit of padding
		scaleY = 640 / (distanceY)

		// Use the smaller scale to ensure both dimensions fit
		zoomLevel = 32+mathUtil.min(scaleX, scaleY)

		// Ensure the zoom level is not too high or too low
		zoomLevel = mathUtil.clamp(zoomLevel, 1, 64)  // Keep the zoom level between 1 and 64

		// Apply the zoom to tile sizes
		outer.tileCellSize = zoomLevel
		ground.cellSize = outer.tileCellSize
		walls.cellSize = outer.tileCellSize

		// Scroll the view to the center point between the players
		scrollTo mathUtil.moveTowards(ground.scrollX, centerX, distance*0.1), mathUtil.moveTowards(ground.scrollY, centerY, distance*0.1)
	end if
end function

scrollTo = function(sx, sy)
	ground.scrollX = sx
	ground.scrollY = sy
	walls.scrollX = sx
	walls.scrollY = sy
	disp.scrollX = sx
	disp.scrollY = sy
	particleDisp.scrollX = sx
	particleDisp.scrollY = sy
end function

reset = function
	scrollTo 0,0
end function


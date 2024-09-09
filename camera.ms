// This module manages the "camera", i.e., the scrolling
// of all displays as needed to keep the player in view.

import "importUtil"
ensureImport "level"

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
		x = player.x
		y = player.y
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
		// Calculate the cell size to ensure square tiles that fit within both dimensions
		outer.tileCellSize = mathUtil.min(960 / ground.extent[0], 640 / ground.extent[1])

		// Apply the same cellSize to both ground and walls
		ground.cellSize = tileCellSize
		walls.cellSize = tileCellSize

		scrollTo 0, 0
	end if
end function

scrollTo = function(sx, sy)
	ground.scrollX = sx
	ground.scrollY = sy
	walls.scrollX = sx
	walls.scrollY = sy
	disp.scrollX = sx
	disp.scrollY = sy
end function

reset = function
	scrollTo 0,0
end function


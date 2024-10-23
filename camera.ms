// This module manages the "camera", i.e., the scrolling
// of all displays as needed to keep the player in view.

import "importUtil"
ensureImport "level"
ensureImport "mathUtil"

min = @mathUtil.min
max = @mathUtil.max

scale = 1
tileCellSize = 64	// Actual size of scaled tiles on screen

camBox = {}
camBox.left = 960/2.25
camBox.right = 960/1.75
camBox.bottom = 220
camBox.top = 300

twoPlayerCamBox = {}
twoPlayerCamBox.left = 64
twoPlayerCamBox.right = 960 - 64
twoPlayerCamBox.bottom = 64
twoPlayerCamBox.top = 640 - 64*2
twoPlayerCamBox.midX = (twoPlayerCamBox.left + twoPlayerCamBox.right)/2
twoPlayerCamBox.midY = (twoPlayerCamBox.bottom + twoPlayerCamBox.top)/2

// Set the following to true to force a dynamic camera, even
// in a 1P game.
kForceDynamicCam = true

// Scroll as needed to get x,y (in world coordinates)
// to be within camBox (in screen coordinates).
updateOnePlayer = function(x,y)
	ground.cellSize = 64
	walls.cellSize = 64
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
end function


// Scroll as needed to get both players (in world coordinates)
// to be within the twoPlayerCamBox (minus some border).
updateTwoPlayer = function
	// Find the min and max in each of X and Y (from player world coordinates).
	x1 = min(player1.lx, player2.lx)
	x2 = max(player1.lx, player2.lx)
	y1 = min(player1.ly, player2.ly)
	y2 = max(player1.ly, player2.ly)
	
	// Now figure out the scale needed in each dimension to make the span
	// between min and max, match the view size.  Then pick the smaller
	// scale, so that both spans are in view.
	xscale = (twoPlayerCamBox.right - twoPlayerCamBox.left) / (x2 - x1)
	yscale = (twoPlayerCamBox.top - twoPlayerCamBox.bottom) / (y2 - y1)
	scale = min(xscale, yscale)
	if scale > 1 then scale = 1
	
	// Then, figure out how much we want to scroll.
	// For now let's just keep the midpoint of the players at the center
	// of the cam box.
	midX = (x2 + x1)/2
	midY = (y2 + y1)/2
	scrollTo midX*scale - twoPlayerCamBox.midX, midY*scale - twoPlayerCamBox.midY, scale
end function


// Scroll as needed to get x,y (in world coordinates)
// to be within camBox (in screen coordinates).
update = function
	if globals.twoplayer or kForceDynamicCam then
		updateTwoPlayer
	else
		updateOnePlayer player1.x, player1.y
	end if
end function

// Scroll the screen such that the bottom-left corner of the screen is
// at sx, sy in world space.  Also, scale the display: scale=1 means
// full size, scale = 0.5 means everything is half as big on screen, etc.
scrollTo = function(sx, sy, scale=1)
	sx *= scale
	sy *= scale
	ground.scrollX = sx
	ground.scrollY = sy
	walls.scrollX = sx
	walls.scrollY = sy
	disp.scrollX = sx
	disp.scrollY = sy
	particleDisp.scrollX = sx
	particleDisp.scrollY = sy
	
	outer.scale = scale
	outer.tileCellSize = 64 * scale
	ground.cellSize = tileCellSize
	walls.cellSize = tileCellSize
end function

reset = function
	scrollTo 0,0
end function


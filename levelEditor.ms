clear
gfx.clear
print "TILE MAP LEVEL EDITOR"
print
print "This program allows you to create, edit, and save an arrangement of tiles."
print

import "tileUtil"
import "textUtil"
sizeToXY = @tileUtil.sizeToXY

EOL = char(13)

min = function(a,b)
	if a < b then return a else return b
end function

max = function(a,b)
	if a > b then return a else return b
end function


getOption = function(optionList)
	text.inverse = true
	print " "
	text.inverse = false
	text.column = text.column - 1
	optionKeys = []
	for opt in optionList
		optionKeys.push opt[0]
	end for
	while true
		k = key.get.upper
		idx = optionKeys.indexOf(k)
		if idx >= 0 then
			print optionList[idx] + EOL
			return optionList[idx]
		end if
	end while
end function


inputNumber = function(prompt, default, help="")
	text.column = 0
	if help then
		print char(13)*2
		r = text.row + 2
		c = text.color
		text.color = color.gray
		print help
		text.row = r
		text.column = 0
		text.color = c
	end if
	print prompt + " [" + default + "]: "
	c = text.column
	s = input
	if help then
		text.row = r - 2
		print " " * 67
		text.row = r - 1
		text.column = 0
	end if
	if s == "" then
		text.row = text.row + 1
		text.column = c
		print default + char(13)
		return default
	end if
	return val(s)
end function

editMapParams = function
	d = sizeToXY(tiles.tileSetTileSize)
	d.x = inputNumber("Tile set tile width ", d.x, "Width of one tile in the tile set image, in pixels.")
	d.y = inputNumber("Tile set tile height", d.y, "Height of one tile in the tile set image, in pixels.")
	tiles.tileSetTileSize = [d.x, d.y]
    tiles2.tileSetTileSize = [d.x, d.y]
	
	d = sizeToXY(tiles.extent)
	d.x = inputNumber("Tile map columns ", d.x, "Extent (in X) of your level layout, in tiles.")
	d.y = inputNumber("Tile map rows    ", d.y, "Extent (in Y) of your level layout, in tiles.")
	tiles.extent = [d.x, d.y]
    tiles2.extent = [d.x, d.y]
	
	d = sizeToXY(tiles.cellSize)
	d.x = inputNumber("Tile map tile width ", d.x, "Size (width) of a tile on screen, in pixels.")
	d.y = inputNumber("Tile map tile height", d.y, "Size (height) of a tile on screen, in pixels.")
	tiles.cellSize = [d.x, d.y]
    tiles2.cellSize = [d.x, d.y]
	
	d = sizeToXY(tiles.overlap)
	d.x = inputNumber("Tile map tile overlap (x)", d.x, "How much (in pixels) tiles should overlap horizontally on screen.")
	d.y = inputNumber("Tile map tile overlap (y)", d.y, "How much (in pixels) tiles should overlap vertically on screen.")
	tiles.overlap = [d.x, d.y]
    tiles2.overlap = [d.x, d.y]
	
    rowOffset = inputNumber("Tile map odd row offset", tiles.oddRowOffset, "Normally 0, but set to 0.5 for row-aligned hex map.")
	tiles.oddRowOffset = rowOffset
    tiles2.oddRowOffset = rowOffset
    colOffset = inputNumber("Tile map odd col offset", tiles.oddColOffset, "Normally 0, but set to 0.5 for column-aligned hex map.")
	tiles.oddColOffset = colOffset
    tiles2.oddColOffset = colOffset
end function	
	
createNew = function
	while true
		globals.tileSetPath = input("Tile set path? (Walls) ") - ".png" + ".png"
		tiles.tileSet = file.loadImage(tileSetPath)
		if tiles.tileSet != null then break
		print "Unable to load image at " + tileSetPath + EOL
	end while
    while true
		globals.tileSetPath2 = input("Tile set path? (Ground) ") - ".png" + ".png"
        tiles2.tileSet = file.loadImage(tileSetPath2)
		if tiles2.tileSet != null then break
		print "Unable to load image at " + tileSetPath2 + EOL
	end while
	tiles.tileSetTileSize = 64
	tiles.cellSize = 64
	tiles.extent = [gfx.width / tiles.cellSize, gfx.height / tiles.cellSize]
	tiles.clear
    tiles2.tileSetTileSize = 64
	tiles2.cellSize = 64
	tiles2.extent = [gfx.width / tiles.cellSize, gfx.height / tiles.cellSize]
	tiles2.clear
	editMapParams
	tiles.clear
    tiles2.clear
	globals.layoutFilePath = ""
end function

loadExisting = function
	while true
		path = findFile
		if not path then continue
		info = file.info(path)
		if not info then
			print "Invalid path." + EOL
			continue
		end if
		if info.isDirectory then
			print "Invalid path (that's a directory, not a file)." + EOL
			continue
		end if		
		globals.layoutFilePath = path
		break
	end while
	tileUtil.loadFromFile layoutFilePath, tiles, tiles2
end function

saveToFile = function
	text.column = 0
	if layoutFilePath == "" then
		globals.layoutFilePath = input("Save layout to path: ")
		if layoutFilePath == "" then return
	end if
	tileUtil.saveToFile layoutFilePath, tiles, tiles2
	print "Saved data to " + layoutFilePath + EOL
	print "(Press any key to continue.)"

    for x in range(0, tiles.extent[0])
        for y in range(0, tiles.extent[1])
            outer.tiles.setCellTint(x, y, color.rgba(255,255,255,255))
            outer.tiles2.setCellTint(x, y, color.rgba(255,255,255,255))
        end for
    end for

	k = key.get
	text.clear
	if k == "q" or k == char(27) then exit
end function

selectBrush = function(index)
	count = tileSetRows * tileSetCols
	if index < 0 then index = index + count
	if index >= count then index = index - count
	globals.brush = index
end function

pickBrushDialog = function
	img = currentTiles.tileSet
	scale = min(512/img.width, 512/img.height)
	destw = img.width * scale
	desth = img.height * scale
	left = 480 - destw/2
	right = 480 + destw/2
	bottom = 320 - desth/2
	top = 320 + desth/2
	gfx.fillRect left-10, bottom-10, destw+20, desth+40, color.gray
	gfx.drawImage img, left, bottom, destw, desth
	cellSize = sizeToXY(tiles.tileSetTileSize)
	for x in range(left, right+1, cellSize.x * scale)
		gfx.line x, top, x, bottom, color.white
	end for
	for y in range(bottom, top+1, cellSize.y * scale)
		gfx.line left, y, right, y, color.white
	end for
	gfx.print "SELECT BRUSH TILE", 400, top + 6, color.black, "small"
	while true
		if not mouse.button or mouse.x < left or mouse.x > right or 
		   mouse.y < bottom or mouse.y > top then continue
		col = floor((mouse.x - left) / (cellSize.x * scale))
		row = floor((top - mouse.y) / (cellSize.y * scale))
		columns = floor(img.width / cellSize.x)
		globals.brush = row * columns + col
		break
	end while
	gfx.fillRect left-10, bottom-10, destw+20, desth+40, color.clear
	while mouse.button; end while
end function

showCursorInfo = function(col, row)
    text.row = 1
	text.column = 0
	print "Layer: " + outer.layer + "    "
	text.row = 0
	text.column = 0
	print "Pixel: " + mouse.x + ", " + mouse.y + "    "
	text.column = 19
	print "Tile: " + col + ", " + row + "    "
	text.column = 33
	val = currentTiles.cell(col, row)
	if val == null then val = "null"
	print "Cell value: " + val + "    "
	text.column = 52
	print "Brush: " + brush
	for i in range(text.column, 67)
		text.setCell i, 0, " "
	end for
end function

showHelp = function
	lines = []
	lines.push "   click - Paint/Erase    "
	lines.push "   arrows - Change Brush  "
	lines.push "   click bar - Pick Brush "
	lines.push "   S - Save               "
	lines.push "   E - Edit Parameters    "
    lines.push "   V - Show Layout        "
	lines.push "   Esc - Exit             "
	lines.push "                          "
	lines.push "   Push mouse against edge"
	lines.push "     of screen to scroll. "
	d = textUtil.Dialog.make("Level Editor Help", lines.join(char(13)))
	d.show
end function

checkKeys = function
	if not key.available then return
	k = key.get.upper
	if k == char(17) then  // left arrow
		selectBrush brush - 1
	else if k == char(18) then  // right arrow
		selectBrush brush + 1
	else if k == char(19) then  // up arrow
		selectBrush brush - tileSetCols
	else if k == char(20) then  // down arrow
		selectBrush brush + tileSetCols
	else if k == "S" then   // Save
		gfx.fillRect 0, 32+24, gfx.width, gfx.height-32, "#000000DD"
        gfx.fillRect 128, 32, gfx.width, gfx.height-32, "#000000DD"
		text.row = 20
		saveToFile
		gfx.fillRect 0, 32+24, gfx.width, gfx.height-32, color.clear	
        gfx.fillRect 128, 32, gfx.width, gfx.height-32, color.clear
	else if k == "E" then   // Edit Parameters
		gfx.fillRect 0, 32, gfx.width, gfx.height-32, "#000000DD"
		text.row = 20
		editMapParams
		text.clear
		gfx.fillRect 0, 32, gfx.width, gfx.height-32, color.clear	
    else if k == "V" then   // Show Layout
        for x in range(0, tiles.extent[0])
            for y in range(0, tiles.extent[1])
                outer.tiles.setCellTint(x, y, color.rgba(255,255,255,255))
                outer.tiles2.setCellTint(x, y, color.rgba(255,255,255,255))
            end for
        end for
	else
		showHelp
	end if
end function

scroll = function(dx, dy)
	sx = tiles.scrollX + 10 * dx
	if sx < 0 then sx = 0
	if sx > tiles.extent[0] * tiles.cellSize[0] - 960 then
		sx = tiles.extent[0] * tiles.cellSize[0] - 960
	end if
	sy = tiles.scrollY + 10 * dy
	if sy < 0 then sy = 0
	if sy > tiles.extent[1] * tiles.cellSize[1] - 640 then
		sy = tiles.extent[1] * tiles.cellSize[1] - 640
	end if
	tiles.scrollX = sx
	tiles.scrollY = sy
    tiles2.scrollX = sx
	tiles2.scrollY = sy
	if display(4).mode == displayMode.tile then
		display(4).scrollX = sx
		display(4).scrollY = sy
	end if
end function

mouseScroll = function
	if mouse.x < 1 then scroll -1, 0
	if mouse.x > gfx.width-2 then scroll 1, 0
	if mouse.y < 1 then scroll 0, -1
	if mouse.y > gfx.height-2 then scroll 0, 1
end function


handleClickInBottomBar = function
	while mouse.button; end while
	pickBrushDialog
end function

handleClickInLayerSelect = function
    while mouse.button; end while
    outer.layer = (outer.layer + 1) % 2
    for x in range(0, currentTiles.extent[0])
        for y in range(0, currentTiles.extent[1])
            outer.currentTiles.setCellTint(x, y, color.rgba(255,255,255,100))
        end for
    end for

    outer.currentTiles = display(7 - outer.layer)
    for x in range(0, currentTiles.extent[0])
        for y in range(0, currentTiles.extent[1])
            outer.currentTiles.setCellTint(x, y, color.rgba(255,255,255,255))
        end for
    end for
    brush = null
end function

drawRectFromMouse = function
    // Define the grid size
    gridSize = 64

    // Helper function to snap a coordinate to the grid
    snapToGrid = function(coord)
        return round(coord / gridSize) * gridSize
    end function

    // Wait for the mouse button to be pressed
    while not mouse.button
        yield
    end while

    // Get the initial mouse down position and snap to grid
    startX = snapToGrid(mouse.x)
    startY = snapToGrid(mouse.y)

    oldEndX = mouse.x
    oldEndY = mouse.y

    // Continue drawing while the mouse button is held down
    while mouse.button
        // Clear the screen (or previous rectangle)
        gfx.drawRect startX, startY, oldEndX - startX, oldEndY - startY, color.clear

        // Calculate the current rectangle size and snap to grid
        endX = snapToGrid(mouse.x)
        endY = snapToGrid(mouse.y)

        // Determine the width and height of the rectangle
        width = abs(endX - startX)
        height = abs(endY - startY)

        // Ensure one dimension is at most 2 grid units
        if width / gridSize > 2 and height / gridSize > 2 then
            if startX + endX > startY + endY then
                width = gridSize * 2
            else
                height = gridSize * 2
            end if
        end if

        // Adjust the end coordinates based on the constrained width and height
        if endX > startX then
            endX = startX + width
        else
            endX = startX - width
        end if

        if endY > startY then
            endY = startY + height
        else
            endY = startY - height
        end if

        // Draw the rectangle from the initial position to the current position
        gfx.drawRect startX, startY, endX - startX, endY - startY

        oldEndX = endX
        oldEndY = endY

        // Yield to allow screen updates
        yield
    end while

    gfx.drawRect startX, startY, oldEndX - startX, oldEndY - startY, color.clear

	xLen = abs(min(startX, endX) - max(startX, endX)) / gridSize
	yLen = abs(min(startY, endY) - max(startY, endY)) / gridSize
    // Once the mouse button is released, fill the rectangle with tile ID 1 on the tile display
    for x in range(min(startX, endX) / gridSize, max(startX, endX) / gridSize - 1, 1)
        for y in range(min(startY, endY) / gridSize, max(startY, endY) / gridSize - 1, 1)
			if xLen == 1 and yLen == 1 then
				currentTiles.setCell(x, y, 0)
			else if yLen == 1 then
				if x == min(startX, endX) / gridSize then
					currentTiles.setCell(x, y, 1)
				else if x == max(startX, endX) / gridSize - 1 then
					currentTiles.setCell(x, y, 3)
				else
					currentTiles.setCell(x, y, 2)
				end if
			else if xLen == 1 then
				if y == min(startY, endY) / gridSize then
					currentTiles.setCell(x, y, 51)
				else if y == max(startY, endY) / gridSize - 1 then
					currentTiles.setCell(x, y, 19)
				else
					currentTiles.setCell(x, y, 35)
				end if
			else if yLen == 2 then
				if y != min(startY, endY) / gridSize then
					if x == min(startX, endX) / gridSize then
						currentTiles.setCell(x, y, 16)
					else if x == max(startX, endX) / gridSize - 1 then
						currentTiles.setCell(x, y, 18)
					else
						currentTiles.setCell(x, y, 17)
					end if
				else
					if x == min(startX, endX) / gridSize then
						currentTiles.setCell(x, y, 32)
					else if x == max(startX, endX) / gridSize - 1 then
						currentTiles.setCell(x, y, 34)
					else
						currentTiles.setCell(x, y, 33)
					end if
				end if
			else
				if x == min(startX, endX) / gridSize then
					if y == min(startY, endY) / gridSize then
						currentTiles.setCell(x, y, 80)
					else if y == max(startY, endY) / gridSize - 1 then
						currentTiles.setCell(x, y, 48)
					else
						currentTiles.setCell(x, y, 64)
					end if
				else
					if y == min(startY, endY) / gridSize then
						currentTiles.setCell(x, y, 81)
					else if y == max(startY, endY) / gridSize - 1 then
						currentTiles.setCell(x, y, 49)
					else
						currentTiles.setCell(x, y, 65)
					end if
				end if
			end if
        end for
    end for
end function

brush = 0
layer = 0
erasing = false

// Main edit loop: paint the map with the mouse!
editLoop = function
	cellSize = sizeToXY(tiles.cellSize)
	overlap = sizeToXY(tiles.overlap)
	grid = {"x":cellSize.x + overlap.x, "y":cellSize.y + overlap.y}
	mouseWasDown = false

	while not key.pressed("escape") and not key.pressed("q")
		checkKeys
		row = floor((mouse.y + tiles.scrollY) / grid.y)
		col = floor((mouse.x + tiles.scrollX) / grid.x)
		if mouse.button then
			if not mouseWasDown then
				if mouse.y < 32 then
					handleClickInBottomBar
					continue
                else if mouse.y < 64 and mouse.x < 128 then
					handleClickInLayerSelect
					continue
				end if
				erasing = (currentTiles.cell(col,row) == brush)
			end if
			if erasing then
				currentTiles.setCell col, row, null
			else
				currentTiles.setCell col, row, brush
			end if
			mouseWasDown = true
		else
			mouseWasDown = false
			if mouse.button(1) then
				// right-click: set brush to current tile
				selectBrush currentTiles.cell(col, row)
			end if
		end if
		showCursorInfo col, row
		mouseScroll
		yield
	end while
end function

display(7).mode = displayMode.tile
tiles2 = display(7)
tiles2.clear
tiles2.scrollX = 0
tiles2.scrollY = 0
tiles2.oddRowOffset = 0
tiles2.oddColOffset = 0

display(6).mode = displayMode.tile
tiles = display(6)
tiles.clear
tiles.scrollX = 0
tiles.scrollY = 0
tiles.oddRowOffset = 0
tiles.oddColOffset = 0

currentTiles = display(6)

display(5).mode = displayMode.pixel
gfx = display(5)
gfx.clear color.clear
gfx.fillRect 0, 0, gfx.width, 32, "#00000088"
gfx.fillRect 0, 32, 128, 24, "#00000088"

text.delimiter = ""
_printMark "`N`ew layout, or `L`oad existing layout? "
if getOption(["New", "Load"]) == "New" then
	createNew
else
	loadExisting
end if
tileSetTileSize = sizeToXY(tiles.tileSetTileSize)
tileSetRows = floor(tiles.tileSet.height / tileSetTileSize.y)
tileSetCols = floor(tiles.tileSet.width / tileSetTileSize.x)

text.clear

handleClickInLayerSelect
editLoop

key.clear
text.delimiter = EOL

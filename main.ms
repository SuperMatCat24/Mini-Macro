
import "importUtil"
ensureImport "constants"
ensureImport "inputs"
ensureImport "mapUtil"
ensureImport "images"
ensureImport "upgrades"
ensureImport "objects"
ensureImport "camera"
ensureImport "particles"
ensureImport "stackedSprite"
ensureImport "mathUtil"
ensureImport "sound"
ensureImport "kart"
ensureImport "pathUtil"
ensureImport "ui"
ensureImport "menu"
ensureImport "highscore"

musicVol = 0.2
soundVol = 2

print "Loading music..."
mus = file.loadSound("mus.ogg")
mus.loop = true
mus.play
mus.adjust musicVol
print "Music loaded!"

Sprite.isOnScreen = function
	if self.x + 64 - disp.scrollX <= 0 then return false
	if self.x - 64 - disp.scrollX >= 960 then return false
	if self.y + 64 - disp.scrollY <= 0 then return false
	if self.y - 64 - disp.scrollY >= 960 then return false
	return true
end function

Sprite.lx = 0
Sprite.ly = 0
Sprite.lScale = 1

checkpoint1 = [[6, 9, 7, 1], [17, 14, 1, 9], [24, 9, 9, 1], [15, 5, 1, 7]]
checkpoint2 = [[5, 14, 7, 1], [19, 18, 1, 7], [31, 14, 9, 1], [12, 11, 1, 5]]
checkpoint3 = [[15, 15, 1, 5], [45, 17, 11, 1], [32, 24, 1, 3], [5, 19, 7, 1]]
checkpoint4 = [[5, 14, 7, 1], [19, 16, 1, 3], [32, 14, 9, 1], [10, 11, 1, 5]]
checkpoint5 = [[3, 14, 3, 1], [28, 19, 1, 7], [35, 15, 7, 1], [26, 7, 1, 7]]
checkpoint6 = [[5, 16, 13, 1], [19, 19, 1, 11], [29, 11, 15, 1], [19, 5, 1, 11]]
checkpoint7 = [[6, 16, 13, 1], [19, 19, 1, 11], [29, 11, 15, 1], [19, 5, 1, 11]]
checkpoint8 = [[7, 8, 3, 1], [24, 20, 1, 5], [35, 11, 9, 1], [11, 4, 1, 5]]
checkpoint9 = [[7, 7, 5, 1], [20, 21, 1, 5], [34, 18, 11, 1], [11, 4, 1, 5]]
checkpoint10 = [[4, 8, 5, 1], [15, 14, 3, 1], [17, 22, 1, 5], [36, 16, 7, 1]]

path1 = [[6, 10], [7, 15], [10, 16], [15, 14], [18, 12], [22, 11], [23, 8], [21, 5], [18, 4], [9, 4], [6, 10]]
for p in path1
    p[0] *= 64; p[1] *= 64
end for
path2 = [[6, 12], [5, 18],  [7, 21], [10, 19], [15, 19], [23, 17], [29, 16], [29, 12], [25, 10], [20, 11], [13, 11], [6, 12]]
for p in path2
    p[0] *= 64; p[1] *= 64
end for
path3 = [[13, 15], [20, 15],  [28, 14], [30, 10], [36, 14], [41, 10], [45, 14], [44, 21], [42, 25], [36, 22], [32, 24], [26, 22], [6, 23], [6, 17], [10, 16], [13, 15]]
for p in path3
    p[0] *= 64; p[1] *= 64
end for
path4 = [[6, 12], [5, 17],  [7, 20], [10, 21], [17, 19], [17, 16], [21, 16], [29, 20], [33, 16], [31, 11], [24, 9], [15, 11], [12, 13], [6, 12]]
for p in path4
    p[0] *= 64; p[1] *= 64
end for
path5 = [[5, 10], [4, 17], [6, 19], [10, 19], [14, 21], [20, 19], [27, 19], [33, 21], [37, 17], [34, 11], [31, 6], [23, 8], [15, 11], [5, 10]]
for p in path5
    p[0] *= 64; p[1] *= 64
end for
path6 = [[3, 15], [6, 20], [11, 21], [18, 20], [20, 18], [26, 15], [29, 13], [31, 9], [24, 5], [19, 9], [11, 11], [9, 14], [3, 15]]
for p in path6
    p[0] *= 64; p[1] *= 64
end for
path7 = [[6, 15], [9, 20], [18, 20], [26, 19], [26, 15], [29, 16], [31, 9], [24, 5], [19, 9], [11, 11], [9, 14], [3, 15]]
for p in path7
    p[0] *= 64; p[1] *= 64
end for
path8 = [[7, 8], [5, 11], [6, 17], [9, 20], [18, 21], [24, 19], [31, 21], [35, 19], [38, 15], [37, 10], [31, 8], [23, 5], [7, 4]]
for p in path8
    p[0] *= 64; p[1] *= 64
end for
path9 = [[6, 7], [6, 12], [3, 17], [3, 20], [7, 21], [10, 21], [17, 24], [24, 19], [30, 20], [37, 18], [35, 8], [28, 6], [18, 5], [8, 3]]
for p in path9
    p[0] *= 64; p[1] *= 64
end for
path10 = [[4, 8], [7, 11], [12, 7], [16, 8], [15, 16], [4, 16], [3, 21], [11, 22], [18, 22], [22, 18], [28, 22], [32, 23], [33, 17], [36, 15], [33, 7], [20, 2], [10, 2], [4, 4]]
for p in path10
    p[0] *= 64; p[1] *= 64
end for

path = path1

clear

display(2).mode = displayMode.text
text = display(2)
text.clear

display(3).mode = displayMode.pixel
gfx = display(3)
gfx.clear

disp = display(4)
disp.clear

display(6).mode = displayMode.tile
ground = display(6)
ground.clear
display(5).mode = displayMode.tile
walls = display(5)
walls.clear

p1Images = []
p2Images = []

player = new kart.PlayerKart
player2 = null

menu.mainMenu

twoplayer = false

if globals.hasIndex("numPlayers") and numPlayers == 2 then
	player.inputs = inputs.inputsForPlayer(1)
	player2 = new kart.PlayerKart
	player2.inputs = inputs.inputsForPlayer(2)
    twoplayer = true
else
	player.inputs = inputs.inputsForPlayer(0)
	player2 = new kart.EnemyKart
end if

player.images = p1Images
player2.images = p2Images

player.init 0
player2.init 1

level.setup

gfx.clear
ui.update player
ui.update player2

coinTimer = 0

lastTileUpdate = time
curTileFrame = 0

lastTime = time
while true
    yield
    dt = time-lastTime
    lastTime = time
    coinTimer += dt

    for a in updatable.all
        if not (a isa Sprite or a isa UpdatableSprite or a isa StackedSprite) then continue
        a.x = a.lx * ground.cellSize / 64
        a.y = a.ly * ground.cellSize / 64
        a.scale = a.lScale * ground.cellSize / 64
    end for

    if coinTimer > 25 then
        objects.regenCoins
        coinTimer = 0
    end if

    if time > lastTileUpdate + 0.15 then
        lastTileUpdate = time
        curTileFrame += 1
        curTileFrame = (curTileFrame + images.tileset2.len) % images.tileset2.len
        ground.tileSet = images.tileset2[curTileFrame]
    end if

    updatable.update dt
    camera.update 
end while
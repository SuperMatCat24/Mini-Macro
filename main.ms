
import "importUtil"
ensureImport "settings"
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
ensureImport "uiElements"
ensureImport "ui"
ensureImport "menu"
ensureImport "highscore"

settings.loadSettings

print "Loading music..."
mus = file.loadSound("mus.ogg")
mus.loop = true
mus.play
mus.adjust settings.musicVol
print "Music loaded!"

// ---------- Utility functions ----------

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

updateSpritePositions = function
    // Loop though all updatableSprites and change positions and scale
    // to act as a dynamic camera.
    for a in updatable.all
        if not (a isa Sprite or a isa UpdatableSprite or a isa StackedSprite) then continue
        a.x = a.lx * camera.tileCellSize / 64
        a.y = a.ly * camera.tileCellSize / 64
        a.scale = a.lScale * camera.tileCellSize / 64
    end for
end function

// ---------- Init Displays ----------

clear

display(1).mode = displayMode.text
text = display(1)
text.clear

display(2).mode = displayMode.pixel
gfx = display(2)
gfx.clear

display(3).mode = displayMode.sprite
disp = display(3)
disp.clear

display(4).mode = displayMode.sprite
particleDisp = display(4)
particleDisp.clear

display(5).mode = displayMode.tile
walls = display(5)
walls.clear

display(6).mode = displayMode.tile
ground = display(6)
ground.clear

// ---------- Init Game ----------

twoplayer = false

path = constants.paths[0]

p1Images = []
p2Images = []

player1 = new kart.PlayerKart
player1.currentUpgrades = []
player2 = null

menu.mainMenu

if globals.hasIndex("numPlayers") and numPlayers == 2 then
	player1.inputs = inputs.inputsForPlayer(1)
	player2 = new kart.PlayerKart
	player2.inputs = inputs.inputsForPlayer(2)
    twoplayer = true
else
	player1.inputs = inputs.inputsForPlayer(0)
	player2 = new kart.EnemyKart
end if
player2.currentUpgrades = []

player1.images = p1Images; player2.images = p2Images
player1.init 0; player2.init 1

level.setup

gfx.clear
ui.update player1; ui.update player2

coinTimer = 0

lastTileUpdate = time
curTileFrame = 0

lastTime = time
while true
    yield
    dt = time-lastTime
    lastTime = time
    coinTimer += dt

    updateSpritePositions

    if coinTimer > 25 then
        objects.regenCoins
        coinTimer = 0
    end if

    if time > lastTileUpdate + 0.15 then
        // Change the ground tileset every 0.15 seconds 
        lastTileUpdate = time
        curTileFrame += 1
        curTileFrame = (curTileFrame + images.tileset2.len) % images.tileset2.len
        ground.tileSet = images.tileset2[curTileFrame]
    end if

    updatable.update dt
    camera.update 

    key.clear // Clear key buffer in case of a crash.
end while
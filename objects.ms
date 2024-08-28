
// Define a special tile index that is invisible, but means
// "there is a collectible here"
COLLECTIBLE_TILE_IDX = 21

//----------------------------------------------------------------------
Coin = new Sprite
Coin.image = file.loadImage("pics/coin.png")
Coin.scale = 4
Coin.instances = []
Coin.active = true

Coin.place = function(tileX, tileY)
	coin = new Coin
	coin.x = tileX * 64 + 32
    coin.y = tileY * 64 + 32
    coin.tileX = tileX
    coin.tileY = tileY
    disp.sprites.push coin
    walls.setCell tileX, tileY, 9
    self.localBounds = new Bounds
    self.localBounds.width = self.image.width
    self.localBounds.height = self.image.height
	Coin.instances.push coin
end function

Coin.collect = function(racer=null)
    if not self.active then return
	racer.coins += 1
    racer.score += constants.coinGetScore
	disp.sprites.removeVal self
    //Coin.instances.removeVal self
    self.active = false
    ui.update racer
	sound.daDing.stop
	sound.daDing.play
	sound.daDing.adjust 0.2 * globals.soundVol, 0, mathUtil.randRange(0.9, 1.2)
end function

clear = function
    for c in Coin.instances
        disp.sprites.removeVal c
    end for
    Coin.instances = []
end function

regenCoins = function
    for c in Coin.instances
        if c.active == true then continue
        disp.sprites.push c
        c.active = true
    end for
end function
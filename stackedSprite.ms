
import "importUtil"
ensureImport "updatable"

globals.createFrames = function(sheet, frameWidth, frameHeight)
    // Split the image into frames
    frames = []
    for i in range(0, sheet.width / frameWidth - 1)
        srcX = (i * frameWidth) % sheet.width
        srcY = 0
        frame = sheet.getImage(srcX, srcY, frameWidth, frameHeight)
        frames.push(frame)
    end for
    return frames
end function

globals.StackedSprite = new updatable.Updatable
StackedSprite.x = 0; StackedSprite.y = 0
StackedSprite.scale = 1
StackedSprite.rotation = 0
StackedSprite.tint = color.white
StackedSprite.images = []
StackedSprite.sprites = []
StackedSprite.localBounds = null
StackedSprite.worldBounds = null

StackedSprite.init = function
	self.changeImages(self.images)
	super.init
end function

StackedSprite.changeImages = function(images)
	// Loops through all of the given images,
	// and creates a sprite for each one.
	self.images = images
	for sprite in self.sprites
		disp.sprites.removeVal sprite
	end for
	self.sprites = []
	for image in self.images
		s = new Sprite 
		s.image = image
		s.x = self.x; s.y = self.y
		s.scale = self.scale
		s.rotation = self.rotation
		s.tint = self.tint
		if self.localBounds then s.localBounds = self.localBounds
		disp.sprites.push s
		self.sprites.push s
	end for
	self.updateSprites
end function

StackedSprite.contains = function(x, y)
	return self.sprites[0].contains(x,y)
end function

StackedSprite.overlaps = function(other)
	return self.sprites[0].overlaps(other)
end function

StackedSprite.update = function(dt=0.0167)
	super.update dt
	self.localBounds = self.sprites[0].localBounds
	self.worldBounds = self.sprites[0].worldBounds
	self.updateSprites
end function

StackedSprite.updateSprites = function
	// Loop through all of our sprites,
	// and make sure its position and scale is the same as ours. 
	// Increases the y position to make it look 3D.
	for i in self.sprites.indexes
		s = self.sprites[i]
		s.x = self.x; s.y = self.y + i*self.scale
		s.scale = self.scale
		s.rotation = self.rotation + 90
		s.tint = self.tint
	end for
end function
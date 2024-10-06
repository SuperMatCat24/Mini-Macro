Button = new UpdatableSprite
Button.bigImage = file.loadImage("pics/bigButton.png")
Button.regImage = file.loadImage("pics/button.png")
Button.smallImage = file.loadImage("pics/miniButton.png")
Button.size = 1
Button.color = color.white
Button.pressedColor = color.silver
Button.disabledColor = color.gray
Button.wasDown = false
Button.text = "START"
Button.instances = []
Button.disabled = false
Button.scale = 4

Button.init = function(changeImages = true)
    super.init
	if changeImages then
    	if self.size == 0 then 
    	    self.image = self.smallImage
    	else if self.size == 1 then 
			self.image = self.regImage
		else
    	    self.image = self.bigImage
    	end if
	end if
    disp.sprites.push self

	self.printText
	
    Button.instances.push self
end function

Button.make = function(x, y, txt, size=1, regColor="#FFFFFF", pressColor="#AAAAAA", disableColor="#777777")
	b = new self
	b.x = x; b.y = y
	b.text = txt
	b.size = size
	b.color = regColor
	b.pressedColor = pressColor
	b.disabledColor = disableColor
	b.init
	return b
end function

Button.printText = function
	gfx.fillRect self.x-self.image.width*self.scale/2, self.y-self.image.height*self.scale/2, self.image.width*self.scale, self.image.height*self.scale, color.clear
	gfx.print self.text, self.x-self.text.len*10, self.y-32/2+5, color.black, "large"
end function

Button.die = function
    super.die
    disp.sprites.removeVal self
    gfx.fillRect self.x-self.text.len*10+2, self.y-32/2+5, self.text.len*20, 20+24, color.clear
end function

Button.clear = function
    for b in Button.instances; b.die; end for
    Button.instances = []
end function

Button.isClicked = function

	if self.disabled == true then
		self.tint = self.disabledColor
		return
	end if

    isDown = mouse.button
	// Ensure the self has a bounds.
	if not self.localBounds then
		self.localBounds = new Bounds
		self.localBounds.width = self.image.width
		self.localBounds.height = self.image.height
	end if
	if self.contains(mouse) then
		self.tint = self.pressedColor
        if self.wasDown and not isDown then 
            sound.blip.play
			sound.blip.adjust settings.soundVol
			self.wasDown = isDown
            return true
        end if
	else
		self.tint = self.color
	end if
	// Return whether the mouse was released within bounds.
    self.wasDown = isDown
	return false
end function

Button.onClick = function
end function

UpgradeButton = new Button
UpgradeButton.image = file.loadImage("pics/abilities/paper.png")
UpgradeButton.upgrade = null
UpgradeButton.size = 3
UpgradeButton.highlighted = false
UpgradeButton.instances = []
UpgradeButton.channel = 0
UpgradeButton.targetPlayer = null

UpgradeButton.make = function(x, y, upgrade, target, size=0, regColor="#FFFFFF", pressColor="#AAAAAA", disableColor="#777777")
	b = new self
	b.x = x; b.y = y
	b.upgrade = upgrade
	b.size = size
	b.color = regColor
	b.pressedColor = pressColor
	b.disabledColor = disableColor
	b.text = upgrade.descriptions[upgrade.level]
	b.targetPlayer = target
	b.image = upgrade.icons[size][upgrade.level]
	b.init
	return b
end function

lastIndexOf = function(s, chr)
    for i in range(s.len-1, 0, -1)
        if s[i] == chr then return i
    end for
    return null  // Return null if the character is not found
end function

UpgradeButton.init = function
	super.init false
	UpgradeButton.instances.push self
end function

UpgradeButton.die = function
	super.die
	UpgradeButton.instances.removeVal self
end function 	

UpgradeButton.printText = function
	if self.size == 0 then 
		self.printTextBig
	else
		self.printTextSmall
	end if
end function

UpgradeButton.printTextSmall = function
	maxLength = 20
	chunks = []

	while self.text.len > 0
		// Find the largest substring that fits within maxLength
		if self.text.len <= maxLength then
			chunk = self.text  // If the remaining text is short enough, take it all
			self.text = ""  // Clear the remaining text
		else
			// Look for the last space within the maxLength boundary
			chunk = self.text[:maxLength]
			spaceIndex = lastIndexOf(chunk, " ")
			if spaceIndex == null then
				spaceIndex = maxLength  // No space found, so take the max length
			end if

			chunk = self.text[:spaceIndex]  // Take up to the space
			self.text = self.text[spaceIndex+1:]  // Remove the chunk (plus the space) from text
		end if

		chunks.push(chunk)  // Add the chunk to the list
	end while

	for i in range(0, chunks.len-1)
		gfx.print chunks[i], self.x+16, self.y+30+19*-i, color.black, "medium"
	end for
	txt = "Price: " + self.upgrade.prices[self.upgrade.level]
	if self.upgrade.prices[self.upgrade.level] > self.targetPlayer.coins then 
		txt = "Too Expensive!"
		self.disabled = true
	end if
	gfx.print txt, self.x+16, self.y-self.image.height*1.67, color.black, "medium"
	txt = self.upgrade.name
	gfx.print txt, self.x+16, self.y+self.image.height*1.37, color.black, "medium"
end function

UpgradeButton.printTextBig = function
	maxLength = 18
	chunks = []
	
	while self.text.len > 0
		// Find the largest substring that fits within maxLength
		if self.text.len <= maxLength then
			chunk = self.text  // If the remaining text is short enough, take it all
			self.text = ""  // Clear the remaining text
		else
			// Look for the last space within the maxLength boundary
			chunk = self.text[:maxLength]
			spaceIndex = lastIndexOf(chunk, " ")
			if spaceIndex == null then
				spaceIndex = maxLength  // No space found, so take the max length
			end if
			
			chunk = self.text[:spaceIndex]  // Take up to the space
			self.text = self.text[spaceIndex+1:]  // Remove the chunk (plus the space) from text
		end if
		
		chunks.push(chunk)  // Add the chunk to the list
	end while
	
	for i in range(0, chunks.len-1)
		gfx.print chunks[i], self.x-self.image.width*1.6, self.y-32/2+7+24*-i, color.black, "normal"
	end for
	txt = "Price: " + self.upgrade.prices[self.upgrade.level]
	if self.upgrade.prices[self.upgrade.level] > self.targetPlayer.coins then 
		txt = "Too Expensive!"
		self.disabled = true
	end if
	gfx.print txt, self.x-self.image.width*1.6, self.y-self.image.height*1.78, color.black, "normal"
	txt = self.upgrade.name
	gfx.print txt, self.x-self.image.width*1.6, self.y+self.image.height*1.73, color.black, "normal"
end function

UpgradeButton.isClicked = function

	if self.disabled == true then
		self.tint = color.gray
		return
	end if

	if self.highlighted == true then
		self.tint = color.orange
		return
	end if

	isDown = mouse.button
	// Ensure the self has a bounds.
	if not self.localBounds then
		self.localBounds = new Bounds
		self.localBounds.width = self.image.width
		self.localBounds.height = self.image.height
	end if
	if self.contains(mouse) then
		self.tint = color.silver
		if self.wasDown and not isDown then 
			sound.blip.play
			for b in UpgradeButton.instances
				if b == self then continue
				if b.channel != self.channel then continue
				b.highlighted = false
			end for
			self.highlighted = true
			return true
		end if
	else
		self.tint = color.white
	end if
	// Return whether the mouse was released within bounds.
	self.wasDown = isDown
	return false
end function

Slider = new updatable.Updatable
Slider.x = 0; Slider.y = 0
Slider.width = 100; Slider.height = 20
Slider.radius = 20
Slider.value = 0.5
Slider.dragging = false
Slider.text = "Slider:"

Slider.make = function(x, y, width=100, height=20, radius=20, value = 0.5, txt="Slider:")
	s = new self
	s.x = x; s.y = y
	s.text = txt
	s.width = width
	s.height = height
	s.radius = radius
	s.value = value
	return s
end function

Slider.draw = function
    gfx.fillRect self.x-self.radius, self.y - self.radius - self.height/2, self.width + self.radius*2, self.height + self.radius*2, color.clear
    // Draw the slider bar
    gfx.fillRect self.x, self.y - self.height/2, self.width, self.height, color.gray
    // Draw the knob
    knobX = self.x + self.value * self.width
    gfx.fillEllipse knobX - self.radius, self.y - self.radius, self.radius * 2, self.radius * 2, color.silver
	// Print text
    gfx.print self.text, self.x-self.text.len*20-self.radius, self.y-14, color.silver, "large"
end function

Slider.updateSlider = function
    mouseX = mouse.x
    // Clamp the mouseX within the slider's bounds
    if mouseX < self.x then mouseX = self.x
    if mouseX > self.x + self.width then mouseX = self.x + self.width
    // Update the value based on the clamped mouseX position
    self.value = (mouseX - self.x) / self.width
end function

Slider.update = function(dt=0.0167)
    // Draw the slider
    self.draw
    // Check for mouse input
    if mouse.button then
        if self.isKnobClicked then self.dragging = true
        if self.dragging then self.updateSlider
    else if self.dragging == true then
        self.dragging = false
		sound.blip.play
		sound.blip.adjust settings.soundVol
    end if
end function

Slider.isKnobClicked = function
    knobX = self.x + self.value * self.width
    dist = (mouse.x - knobX)^2 + (mouse.y - self.y)^2
    return dist <= self.radius^2
end function

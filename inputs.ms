// This module defines the Inputs class, which collects
// keyboard/gamepad inputs for one player.

// Function names: indexed by [functionNum]
functions = ["Up", "Down", "Left", "Right", "Fire"]

// Function index constants
kUp = 0
kDown = 1
kLeft = 2
kRight = 3
kDrift = 4

// Inputs: indexed by [functionNum][alternate]
p1Inputs = [
	["w", "Joy1Axis2 +"],
	["s", "Joy1Axis2 -"],
	["a", "Joy1Axis1 -"],
	["d", "Joy1Axis1 +"],
	["space", "joystick 1 button 1"]]

p2Inputs = [
	["up", "Joy2Axis2 -"],
	["down", "Joy2Axis2 +"],
	["left", "Joy2Axis1 -"],
	["right", "Joy2Axis1 -"],
	["right shift", "joystick 2 button 1"]]

allInputs = [p1Inputs, p2Inputs]

// isInputActive: check whether the given key is pressed
// or axis is deflected.
isInputActive = function(inputStr)
	if not inputStr then return false
	if inputStr.len > 3 and inputStr[:3] == "Joy" then
		// check an axis
		if inputStr[-2:] == " +" then
			return key.axis(inputStr[:-2]) > 0.1
		else
			return key.axis(inputStr[:-2]) < -0.1
		end if
	end if
	// check a key/button
	return key.pressed(inputStr)
end function

// isPressed: return whether the primary or alternate
// input for the given 0-based player and input function is pressed.
isPressed = function(playerNum, functionIdx)
	return isInputActive(allInputs[playerNum][functionIdx][0]) or
	  isInputActive(allInputs[playerNum][functionIdx][1])
end function

Inputs = {}
Inputs.playerNum = 0		// 1 (left), 2 (right), or 0 (both)

Inputs.horizontal = function
	left = 0; right = 0
	if self.playerNum == 0 then
		left = isPressed(0, kLeft) or isPressed(1, kLeft)
		right = isPressed(0, kRight) or isPressed(1, kRight)
	else
		left = isPressed(self.playerNum-1, kLeft)
		right = isPressed(self.playerNum-1, kRight)
	end if
	return right - left
end function

Inputs.vertical = function
	up = 0; down = 0
	if self.playerNum == 0 then
		down = isPressed(0, kDown) or isPressed(1, kDown)
		up = isPressed(0, kUp) or isPressed(1, kUp)
	else
		down = isPressed(self.playerNum-1, kDown)
		up = isPressed(self.playerNum-1, kUp)
	end if
	return up - down
end function

Inputs.drift = function
	if self.playerNum == 0 then
		return isPressed(0, kDrift) or isPressed(1, kDrift)
	else
		return isPressed(self.playerNum-1, kDrift)
	end if
end function

inputsForPlayer = function(playerNum)
	result = new Inputs
	result.playerNum = playerNum
	return result
end function
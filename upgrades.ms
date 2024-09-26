
Upgrade = {}
Upgrade.name = "NAME"
Upgrade.icons = []
Upgrade.descriptions = ["BUY DESCRIPTION", "UPGRADE DESCRIPTION"]
Upgrade.prices = [10, 20]
Upgrade.level = 0

Compact = new Upgrade
Compact.name = "Compact Engines"
Compact.icons = [
	[file.loadImage("pics/abilities/engine.png"), file.loadImage("pics/abilities/dense.png")],
	[file.loadImage("pics/abilities/engine_small.png"), file.loadImage("pics/abilities/dense_small.png")],
]
Compact.descriptions = ["New engine technology increases your car's top speed, and shrinks it down!", "Upgrades your engine's density, increasing top speed and weight."]
Compact.prices = [40, 45]

Grip = new Upgrade
Grip.name = "Grippier Wheels"
Grip.icons = [
	[file.loadImage("pics/abilities/wheel.png"), file.loadImage("pics/abilities/mudWheel.png")],
	[file.loadImage("pics/abilities/wheel_small.png"), file.loadImage("pics/abilities/mudWheel_small.png")],
]
Grip.descriptions = ["Sports tires have better grip, increasing acceleration!", "Ultra-performance tires can last longer before slowing down on mud and grass!"]
Grip.prices = [20, 45]

ShrinkRay = new Upgrade
ShrinkRay.name = "Shrink Ray"
ShrinkRay.icons = [
	[file.loadImage("pics/abilities/shrinkRay.png"), file.loadImage("pics/abilities/tripleShot.png")],
	[file.loadImage("pics/abilities/shrinkRay_small.png"), file.loadImage("pics/abilities/tripleShot_small.png")],
]
ShrinkRay.descriptions = ["Occasionally shoots out a shrink ray that shrinks and slows down opponents.", "The shrink ray now shoots 3 rays at once!"]
ShrinkRay.prices = [30, 80]

Juggernaut = new Upgrade
Juggernaut.name = "Juggernaut"
Juggernaut.icons = [
	[file.loadImage("pics/abilities/monster.png"), file.loadImage("pics/abilities/boost.png")],
	[file.loadImage("pics/abilities/monster_small.png"), file.loadImage("pics/abilities/boost_small.png")],
]
Juggernaut.descriptions = ["Slows down the car, but increases weight and size!", "Gain a speed boost after hitting your opponent!"]
Juggernaut.prices = [40, 35]

Defence = new Upgrade
Defence.name = "Bulk Up"
Defence.icons = [
	[file.loadImage("pics/abilities/retalliation.png"), file.loadImage("pics/abilities/bulk up.png")],
	[file.loadImage("pics/abilities/retalliation_small.png"), file.loadImage("pics/abilities/bulk up_small.png")],
]
Defence.descriptions = ["Increases scale and weight when hit.", "Increases scale and weight when going fast!"]
Defence.prices = [30, 45]

Drift = new Upgrade
Drift.name = "Drift Boost"
Drift.icons = [
	[file.loadImage("pics/abilities/drift.png"), file.loadImage("pics/abilities/driftScale.png")],
	[file.loadImage("pics/abilities/drift_small.png"), file.loadImage("pics/abilities/driftScale_small.png")],
]
Drift.descriptions = ["Turning while drifting increases drift charge, and boosts you when released!", "Drifting now increases the cars scale and weight."]
Drift.prices = [65, 20]

possibleUpgrades = [Compact, Grip, ShrinkRay, Defence, Juggernaut, Drift]

getUpgrades = function(obj)
	if not obj isa kart.Kart then return null
    
	if obj.currentUpgrades == [] then 
		for pu in upgrades.possibleUpgrades
			obj.currentUpgrades.push new pu
		end for
	end if

	currentUpgrades = obj.currentUpgrades
	possibleUpgrades = []

	for u in currentUpgrades
		if u.level < 2 then possibleUpgrades.push u
	end for
	return possibleUpgrades
end function
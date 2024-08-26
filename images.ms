
import "importUtil"
ensureImport "stackedSprite"

display(2).mode = displayMode.text
text = display(2)
text.clear
text.delimiter = char(13)

print "LOADING IMAGES..."
print "Loading Cars"

carFrames = []

blueCarFrames = file.loadImage("/usr/pics/karts/BlueCar.png")
carFrames.push createFrames(blueCarFrames, 16, 16)

greenCarFrames = file.loadImage("/usr/pics/karts/GreenCar.png")
carFrames.push createFrames(greenCarFrames, 16, 16)

yellowCarFrames = file.loadImage("/usr/pics/karts/YellowCar.png")
carFrames.push createFrames(yellowCarFrames, 16, 16)

redCarFrames = file.loadImage("/usr/pics/karts/RedCar.png")
carFrames.push createFrames(redCarFrames, 16, 16)

purpleCarFrames = file.loadImage("/usr/pics/karts/PurpleCar.png")
carFrames.push createFrames(purpleCarFrames, 16, 16)

print "Car images loaded!"
print "IMAGES LOADED!"

woodPanel = file.loadImage("pics/WoodBG.png")
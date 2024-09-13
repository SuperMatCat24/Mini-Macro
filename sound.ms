bump = new Sound
bump.init 0.2, [200,0], [0.2,0], Sound.triangleWave

ding = new Sound
ding.init 0.2, noteFreq(90), [0.15, 0], Sound.sineWave

blip = new Sound
blip.init 0.1, noteFreq(66), [0.1, 0], Sound.sineWave

daDing = new Sound
daDing.init 0.05, noteFreq(84), [0.2, 0.2, 0]
dd2 = new Sound
dd2.init 0.1, noteFreq(96), [0]*40 + range(0.4,0,-0.01)
daDing.mix dd2

eat = new Sound
eat.init 0.125, noteFreq(12), [0.4, 0.4, 0], Sound.noiseWave
eat2 = new Sound
eat2.init 0.35, noteFreq(32), [0]*40 + range(0.4,0,-0.01), Sound.noiseWave
eat.mix eat2

catch = new Sound
catch.init 0.5, [740, 20], [0.3,0], Sound.noiseWave
catch2 = new Sound
catch2.init 0.2, noteFreq(32), [0]*40 + range(0.3,0,-0.01), Sound.noiseWave
catch.mix catch2

boost = new Sound
boost.init 0.7, [400, 20], [0.25, 0.1, 0.02, 0], Sound.noiseWave
boost2 = new Sound
boost2.init 1.7, [10, 20], [0.2, 0], Sound.noiseWave
boost.mix boost2

skid = new Sound
skid.init 0.7, 680, 0.2
skid.fadeIn = 0
skid.fadeOut = 0
skid.loop = true

skid2 = new Sound
skid2.init 0.7, 280, 0.3, Sound.noiseWave
skid2.fadeIn = 0
skid2.fadeOut = 0
skid2.loop = true
skid.mix skid2

skid3 = new Sound
skid3.init 0.7, 940, 0.2, Sound.noiseWave
skid3.fadeIn = 0
skid3.fadeOut = 0
skid3.loop = true
skid.mix skid3

skid.play
skid.adjust 0

crack = new Sound 
crack.init 1.6, [800, 100, 600, 50, 400, 20, 200, 0], [0.35, 0.15, 0], Sound.noiseWave 
crack2 = new Sound 
crack2.init 0.6, [1800, 100, 1000, 50, 700, 20, 300, 0], [0.25, 0], Sound.sawtoothWave 
crack.mix crack2

suspence = new Sound 
suspence.init 0.2, 200, 0.15, Sound.squareWave 
suspence.fadeIn = 0
suspence.fadeOut = 0
suspence.loop = true

// Announcer sounds using FL Studio text to speech
announce3 = file.loadSound("sfx/three.ogg")
announce2 = file.loadSound("sfx/two.ogg")
announce1 = file.loadSound("sfx/one.ogg")
announce0 = file.loadSound("sfx/go.ogg")

import "importUtil"
ensureImport "listUtil"

spawnRelativeToParent = function(parent, particle, offsetX, offsetY)
    // Calculate the rotation in radians
    rotationRad = parent.rotation * (pi / 180)

    // Calculate the offset position based on the parent's rotation
    relativeX = offsetX * cos(rotationRad) - offsetY * sin(rotationRad)
    relativeY = offsetX * sin(rotationRad) + offsetY * cos(rotationRad)

    // Calculate the new object's position
    newX = parent.lx + relativeX
    newY = parent.ly + relativeY

    p = new particle
    p.parent = parent
    p.lx = newX
    p.ly = newY
    
    p.init
end function

PlayerParticle = new UpdatableSprite
PlayerParticle.image = file.loadImage("pics/driftFull.png")
PlayerParticle.lifetime = 0.5
PlayerParticle.spawnTime = 0
PlayerParticle.lScale = 0.5
PlayerParticle.top = false
PlayerParticle.color = color.rgba(0, 0, 0, 255)
PlayerParticle.instances = []
PlayerParticle.parent = null

PlayerParticle.init = function
    super.init
    if self.top == true then
        disp.sprites.push self
    else
        disp.sprites.insert 0, self
    end if
    self.spawnTime = time
    PlayerParticle.instances.push self
end function

PlayerParticle.die = function
    super.die 
    disp.sprites.removeVal self
    PlayerParticle.instances.removeVal self
end function

PlayerParticle.update = function(dt=0.0167)
    if self.spawnTime + self.lifetime < time then
        self.die
        return
    end if
    remainingTime = self.spawnTime + self.lifetime - time
    lifetimeFraction = remainingTime / self.lifetime

    driftFraction = (self.parent.driftBoost) / self.parent.maxDriftBoost * 255

    alpha = lifetimeFraction * 255
    self.tint = self.color + color.rgba(0,0,0,alpha)[7:9]
end function

VelocityParticle = new PlayerParticle
VelocityParticle.speed = 250
VelocityParticle.scale = 0
VelocityParticle.instances = []

VelocityParticle.init = function
    super.init
   
    dx = self.lx - self.parent.lx
    dy = self.ly - self.parent.ly

    magnitude = sqrt(dx^2 + dy^2)

    self.vx = (dx / magnitude) * self.speed
    self.vy = (dy / magnitude) * self.speed
    VelocityParticle.instances.push self
end function

VelocityParticle.update = function(dt=0.0167)
    if self.spawnTime + self.lifetime < time then
        self.die
        return
    end if
    remainingTime = self.spawnTime + self.lifetime - time
    lifetimeFraction = remainingTime / self.lifetime
    if lifetimeFraction > 0.5 then
        self.lScale = 4 * (1 - (lifetimeFraction - 0.5) / 0.5)
    else
        self.lScale = 2 + (4 - 2) * (lifetimeFraction / 0.5)
    end if

    self.lx += self.vx * dt
    self.ly += self.vy * dt
    VelocityParticle.instances.removeVal self
end function

DriftParticle = new PlayerParticle
DriftParticle.image = file.loadImage("pics/driftFull.png")
DriftParticle.lifetime = 0.5
DriftParticle.isParticle = true
DriftParticle.tint = color.rgba(0, 0, 0, 255)

BoostParticle = new PlayerParticle
BoostParticle.image = file.loadImage("pics/boostFull.png")
BoostParticle.lifetime = 0.3
BoostParticle.scale = 0.6
BoostParticle.top = true

BoostParticle.update = function(dt=0.0167)
    if self.spawnTime + self.lifetime < time then
        self.die
        return
    end if
    remainingTime = self.spawnTime + self.lifetime - time
    lifetimeFraction = remainingTime / self.lifetime
    if lifetimeFraction > 0.5 then
        self.lScale = 4 * (1 - (lifetimeFraction - 0.5) / 0.5)
    else
        self.lScale = 2 + (4 - 2) * (lifetimeFraction / 0.5)
    end if
end function

MudParticle = new VelocityParticle
MudParticle.image = file.loadImage("pics/mudBall.png")
MudParticle.lifetime = 0.3
MudParticle.top = true

DustParticle = new VelocityParticle
DustParticle.image = file.loadImage("pics/dustCloud.png")
DustParticle.lifetime = 0.3
DustParticle.speed = 150
DustParticle.top = true

clear = function
    for p in PlayerParticle.instances
        p.suspend
        disp.sprites.removeVal p
    end for
    PlayerParticle.instances = []
end function
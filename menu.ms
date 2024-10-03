
import "importUtil"
ensureImport "ui"

background = file.loadImage("pics/bg.png")
backgroundCar = file.loadImage("pics/bgcar.png")
logoImg = file.loadImage("pics/logo.png")

mainMenu = function
    ground.clear
	walls.clear
    gfx.clear
    bg = new Sprite
    bg.image = background
    bg.x = 960/2; bg.y = 640/2; bg.scale = 4
    disp.sprites.push bg

	car = new Sprite
    car.image = backgroundCar
    car.x = 960/2; car.y = 640/2; car.scale = 4
    disp.sprites.push car

    logo = new Sprite
    logo.image = logoImg
    logo.x = 960/2; logo.y = 640/2; logo.scale = 4
    disp.sprites.push logo

    play = uiElements.Button.make(960/3, 200, "1 PLAYER")
    play2 = uiElements.Button.make(960/1.5, 200, "2 PLAYER")
    help = uiElements.Button.make(960/3, 100, "HELP")
    settings = uiElements.Button.make(960/1.5, 100, "OPTIONS")

    while true  // (press Control-C to exit)
        yield

        bg.x = bg.image.width*2+((time*-200)%bg.image.width/2*bg.scale)
		car.x =  960/2 + sin(time*0.6)*300
        logo.rotation = sin(time*3) * 2
        if play.isClicked then
            gfx.clear
			uiElements.Button.clear
            disp.sprites = []
            onePlayerMenu
            return
        else if play2.isClicked then
            gfx.clear
			uiElements.Button.clear
            disp.sprites = []
            twoPlayerMenu
            return
        else if settings.isClicked then
            optionsMenu
            return
        else if help.isClicked then
            helpMenu
            return
        end if
    end while
end function

helpMenu = function
    gfx.clear
    uiElements.Button.clear
    bg = new Sprite
    bg.image = images.infoPanel
    bg.y = 320
    bg.x = 960/2
    bg.scale = 4
    disp.sprites.push bg
    
    exit = uiElements.Button.make(910, 590, "X", 0)

    txt = "Score Table:"
    gfx.print txt, 550, 505, color.black, "normal"
    txt = "Win Score: " + constants.winScore
    gfx.print txt, 550, 422, color.black, "normal"
    txt = "Upgrade Score: " + constants.upgradeScore
    gfx.print txt, 550, 372, color.black, "normal"
    txt = "Lap Score: " + constants.lapScore
    gfx.print txt, 550, 314, color.black, "normal"
    txt = "Checkpoint Score: " + constants.checkpointScore
    gfx.print txt, 550, 260, color.black, "normal"
    txt = "Coin Score: " + constants.coinGetScore
    gfx.print txt, 550, 205, color.black, "normal"

    while true
        if exit.isClicked then
            uiElements.Button.clear
            gfx.clear
            disp.sprites = [bg]
            updatable.all = []
            mainMenu
            return
        end if
        yield
    end while
end function

onePlayerMenu = function
    bg = new Sprite
    bg.image = images.woodPanel
    bg.y = 320
    bg.x = 960/2
    bg.scale = 4
    disp.sprites.push bg
    gfx.line 960/2, 0, 960/2, 640, color.black, 20
    gfx.line 960/2, 0, 960/2, 640, color.red, 10

    playerSprite = new StackedSprite
    playerSprite.images = images.carFrames[0]
    playerSprite.sprites = []
    playerSprite.scale = 10
    playerSprite.x = 960*(1/4)
    playerSprite.y = 350
    playerSprite.init
    playerSprite.imageIndex = 0

    playerRightButton = uiElements.Button.make(960*(1/4)+150, 350, ">", 0)
    playerLeftButton = uiElements.Button.make(960*(1/4)-150, 350, "<", 0)
    playerReadyButton = uiElements.Button.make(960*(1/4), 150, "PLAY", 1)
    
    txt = "Choose your car"
    gfx.print txt, 960*(1/4)-txt.len*10, 590, color.white, "large"

    highscore.loadScores
	highscore.showScores
    
    while true
        playerSprite.rotation += 1
        playerSprite.updateSprites

        if playerLeftButton.isClicked then
            playerSprite.imageIndex -= 1
            playerSprite.imageIndex = (playerSprite.imageIndex + images.carFrames.len) % (images.carFrames.len)
            playerSprite.changeImages(images.carFrames[playerSprite.imageIndex])
        else if playerRightButton.isClicked then
            playerSprite.imageIndex += 1
            playerSprite.imageIndex = (playerSprite.imageIndex + images.carFrames.len) % (images.carFrames.len)
            playerSprite.changeImages(images.carFrames[playerSprite.imageIndex])
        else if playerReadyButton.isClicked then
            break
        end if
        yield
    end while
    gfx.clear
    text.clear
    uiElements.Button.clear
    disp.sprites = [player1, player2]

    imageIndex = mathUtil.randRange(0, images.carFrames.len)
    indexMod = (imageIndex + images.carFrames.len) % (images.carFrames.len)
    if indexMod == images.carFrames.indexOf(playerSprite.images) then imageIndex += 1
    imageIndex = (imageIndex + images.carFrames.len) % (images.carFrames.len)

    globals.p1Images = playerSprite.images
    globals.p2Images = images.carFrames[imageIndex]
end function

twoPlayerMenu = function
    bg = new Sprite
    bg.image = images.woodPanel
    bg.y = 320
    bg.x = 960/2
    bg.scale = 4
    disp.sprites.push bg
    gfx.line 960/2, 0, 960/2, 640, color.black, 20
    gfx.line 960/2, 0, 960/2, 640, color.red, 10

    playerSprite = new StackedSprite
    playerSprite.images = images.carFrames[0]
    playerSprite.sprites = []
    playerSprite.scale = 10
    playerSprite.x = 960*(1/4)
    playerSprite.y = 350
    playerSprite.init
    playerSprite.imageIndex = 0

    enemySprite = new StackedSprite
    enemySprite.images = images.carFrames[1]
    enemySprite.sprites = []
    enemySprite.scale = 10
    enemySprite.x = 960*(3/4)
    enemySprite.y = 350
    enemySprite.init
    enemySprite.imageIndex = 1

    playerRightButton = uiElements.Button.make(960*(1/4)+150, 350, ">", 0)
    playerLeftButton = uiElements.Button.make(960*(1/4)-150, 350, "<", 0)
    playerReadyButton = uiElements.Button.make(960*(1/4), 150, "PLAY", 1)
    playerReadyButton.ready = false

    enemyRightButton = uiElements.Button.make(960*(3/4)+150, 350, ">", 0)
    enemyLeftButton = uiElements.Button.make(960*(3/4)-150, 350, "<", 0)
    enemyReadyButton = uiElements.Button.make(960*(3/4), 150, "PLAY", 1)
    enemyReadyButton.ready = false
    
    txt = "Player 1"
    gfx.print txt, 960*(1/4)-txt.len*10, 590, color.white, "large"
    txt = "Player 2"
    gfx.print txt, 960*(3/4)-txt.len*10, 590, color.white, "large"

    changeCarSprite = function(amt, sprite, enemySprite)
        sprite.imageIndex -= 1
        indexMod = (sprite.imageIndex + images.carFrames.len) % (images.carFrames.len)
        if indexMod == enemySprite.imageIndex then sprite.imageIndex -= 1
        sprite.imageIndex = (sprite.imageIndex + images.carFrames.len) % (images.carFrames.len)
        sprite.changeImages(images.carFrames[sprite.imageIndex])
    end function
    
    while true
        // Dont need to use delta time because the menu page will almost never lag
        playerSprite.rotation += 1
        playerSprite.updateSprites
        enemySprite.rotation += 1
        enemySprite.updateSprites

        if playerLeftButton.isClicked then
            changeCarSprite -1, playerSprite, enemySprite
        else if playerRightButton.isClicked then
            changeCarSprite 1, playerSprite, enemySprite
        else if enemyLeftButton.isClicked then
            changeCarSprite -1, enemySprite, playerSprite
        else if enemyRightButton.isClicked then
            changeCarSprite 1, enemySprite, playerSprite
        else if playerReadyButton.isClicked then
            playerReadyButton.ready = not playerReadyButton.ready
            if playerReadyButton.ready == true then
                playerReadyButton.color = color.lime
                playerReadyButton.pressedColor = color.red
            else
                playerReadyButton.color = color.white
                playerReadyButton.pressedColor = color.silver
            end if
        else if enemyReadyButton.isClicked then
            enemyReadyButton.ready = not enemyReadyButton.ready
            if enemyReadyButton.ready == true then
                enemyReadyButton.color = color.lime
                enemyReadyButton.pressedColor = color.red
            else
                enemyReadyButton.color = color.white
                enemyReadyButton.pressedColor = color.silver
            end if
        end if

        if enemyReadyButton.ready == true and playerReadyButton.ready == true then break

        yield
    end while
    globals.numPlayers = 2
    gfx.clear
    uiElements.Button.clear
    disp.sprites = [player1, player2]

    globals.p1Images = playerSprite.images
    globals.p2Images = enemySprite.images
end function

optionsMenu = function
    gfx.clear
    uiElements.Button.clear

    bg = new Sprite
    bg.image = images.woodPanel
    bg.y = 320
    bg.x = 960/2
    bg.scale = 4
    disp.sprites.push bg
    
    exit = uiElements.Button.make(910, 590, "X", 0)

    clearAchivements = uiElements.Button.make(960*(2/8), 50, "Clear Achivements", 2, color.rgb(255, 50, 50), color.rgb(200, 0, 0))
    clearSettings = uiElements.Button.make(960*(6/8), 50, "Clear Settings", 2, color.rgb(255, 50, 50), color.rgb(200, 0, 0))

    mVolume = uiElements.Slider.make(300, 550, 200, 20, 20, settings.musicVol, "Music Volume:")
    sVolume = uiElements.Slider.make(300, 500, 200, 20, 20, settings.soundVol/2, "Sound Volume:")

    while true
        mVolume.update
        settings.musicVol = mVolume.value
        globals.mus.adjust mVolume.value

        sVolume.update
        settings.soundVol = sVolume.value * 2

        settings.saveSettings

        if exit.isClicked then
            sVolume.die
            mVolume.die
            uiElements.Button.clear
            gfx.clear
            disp.sprites = [bg]
            updatable.all = []
            mainMenu
            return
        else if clearAchivements.isClicked then
        else if clearSettings.isClicked then
        end if
        yield
    end while
end function
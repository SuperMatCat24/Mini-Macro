
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

    play = new uiElements.Button
    play.x = 960/3; play.y = 200
    play.text = "PLAY"
    play.init

    help = new uiElements.Button
    help.x = 960/3; help.y = 100
    help.text = "HELP"
    help.init

	settings = new uiElements.Button
    settings.x = 960/1.5; settings.y = 200
    settings.text = "OPTIONS"
    settings.init

    while true  // (press Control-C to exit)
        yield

        bg.x = bg.image.width*2+((time*-200)%bg.image.width/2*bg.scale)
		car.x =  960/2 + sin(time*0.6)*300
        logo.rotation = sin(time*3) * 2

        if play.isClicked then
            gfx.clear
			uiElements.Button.clear
            disp.sprites = []
            playerMenu
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
    
    exit = new uiElements.Button
    exit.x = 910; exit.y = 590
    exit.text = "X"
    exit.size = 0
    exit.init

    txt = "Score Table:"
    gfx.print txt, 550, 505, color.black, "normal"
    txt = "Win Score: " + constants.winScore
    gfx.print txt, 550, 422, color.black, "normal"
    txt = "Upgrade Score: " + constants.upgradeScore
    gfx.print txt, 550, 372, color.black, "normal"
    txt = "Lap Score: " + constants.lapScore
    gfx.print txt, 550, 314, color.black, "normal"
    txt = "Coin Score: " + constants.coinGetScore
    gfx.print txt, 550, 260, color.black, "normal"
    txt = "Loss Score: " + constants.lossScore
    gfx.print txt, 550, 204, color.black, "normal"

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

playerMenu = function
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
    
    playerRightButton = new uiElements.Button
    playerRightButton.size = 0
    playerRightButton.x = 960*(1/4)+150; playerRightButton.y = 350
    playerRightButton.text = ">"
    playerRightButton.init

    playerLeftButton = new uiElements.Button
    playerLeftButton.size = 0
    playerLeftButton.x = 960*(1/4)-150; playerLeftButton.y = 350
    playerLeftButton.text = "<"
    playerLeftButton.init

    enemyRightButton = new uiElements.Button
    enemyRightButton.size = 0
    enemyRightButton.x = 960*(3/4)+150; enemyRightButton.y = 350
    enemyRightButton.text = ">"
    enemyRightButton.init

    enemyLeftButton = new uiElements.Button
    enemyLeftButton.size = 0
    enemyLeftButton.x = 960*(3/4)-150; enemyLeftButton.y = 350
    enemyLeftButton.text = "<"
    enemyLeftButton.init

    playerReadyButton = new uiElements.Button
    playerReadyButton.size = 1
    playerReadyButton.x = 960*(1/4); playerReadyButton.y = 150
    playerReadyButton.text = "READY"
    playerReadyButton.init
    playerReadyButton.ready = false

    enemyReadyButton = new uiElements.Button
    enemyReadyButton.size = 1
    enemyReadyButton.x = 960*(3/4); enemyReadyButton.y = 150
    enemyReadyButton.text = "READY"
    enemyReadyButton.init
    enemyReadyButton.ready = false
    
    txt = "Player 1"
    gfx.print txt, 960*(1/4)-txt.len*10, 590, color.white, "large"

    twoPlayerButton = new uiElements.Button
    twoPlayerButton.size = 1
    twoPlayerButton.x = 960*(3/4); twoPlayerButton.y = 590
    twoPlayerButton.text = "AI Car"
    twoPlayerButton.init
    twoPlayerButton.ai = true
    
    while true
        playerSprite.rotation += 1
        playerSprite.updateSprites
        enemySprite.rotation += 1
        enemySprite.updateSprites

        if playerLeftButton.isClicked then
            playerSprite.imageIndex -= 1
            indexMod = (playerSprite.imageIndex + images.carFrames.len) % (images.carFrames.len)
            if indexMod == enemySprite.imageIndex then playerSprite.imageIndex -= 1
            playerSprite.imageIndex = (playerSprite.imageIndex + images.carFrames.len) % (images.carFrames.len)
            playerSprite.changeImages(images.carFrames[playerSprite.imageIndex])
        else if playerRightButton.isClicked then
            playerSprite.imageIndex += 1
            indexMod = (playerSprite.imageIndex + images.carFrames.len) % (images.carFrames.len)
            if indexMod == enemySprite.imageIndex then playerSprite.imageIndex += 1
            playerSprite.imageIndex = (playerSprite.imageIndex + images.carFrames.len) % (images.carFrames.len)
            playerSprite.changeImages(images.carFrames[playerSprite.imageIndex])
        else if enemyLeftButton.isClicked then
            enemySprite.imageIndex -= 1
            indexMod = (enemySprite.imageIndex + images.carFrames.len) % (images.carFrames.len)
            if indexMod == playerSprite.imageIndex then enemySprite.imageIndex -= 1
            enemySprite.imageIndex = (enemySprite.imageIndex + images.carFrames.len) % (images.carFrames.len)
            enemySprite.changeImages(images.carFrames[enemySprite.imageIndex])
        else if enemyRightButton.isClicked then
            enemySprite.imageIndex += 1
            indexMod = (enemySprite.imageIndex + images.carFrames.len) % (images.carFrames.len)
            if indexMod == playerSprite.imageIndex then enemySprite.imageIndex += 1
            enemySprite.imageIndex = (enemySprite.imageIndex + images.carFrames.len) % (images.carFrames.len)
            enemySprite.changeImages(images.carFrames[enemySprite.imageIndex])
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
        else if twoPlayerButton.isClicked then
            twoPlayerButton.ai = not twoPlayerButton.ai
            if twoPlayerButton.ai == false then
                twoPlayerButton.text = "Player 2"
                globals.numPlayers = 2
            else
                twoPlayerButton.text = "AI Car"
                globals.numPlayers = 1
            end if
            twoPlayerButton.printText
        end if

        if enemyReadyButton.ready == true and playerReadyButton.ready == true then break

        yield
    end while
    gfx.clear
    uiElements.Button.clear
    disp.sprites = [player, player2]

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
    
    exit = new uiElements.Button
    exit.x = 910; exit.y = 590
    exit.text = "X"
    exit.size = 0
    exit.init

    clearAchivements = new uiElements.Button
    clearAchivements.x = 960*(2/8); clearAchivements.y = 50
    clearAchivements.text = "Clear Achivements"
    clearAchivements.size = 2
    clearAchivements.color = color.rgb(255, 50, 50)
    clearAchivements.pressedColor = color.rgb(200, 0, 0)
    clearAchivements.init

    clearSettings = new uiElements.Button
    clearSettings.x = 960*(6/8); clearSettings.y = 50
    clearSettings.text = "Clear Settings"
    clearSettings.size = 2
    clearSettings.color = color.rgb(255, 50, 50)
    clearSettings.pressedColor = color.rgb(200, 0, 0)
    clearSettings.init

    mVolume = new uiElements.Slider
    mVolume.x = 300
    mVolume.y = 550
    mVolume.width = 200
    mVolume.text = "Music Volume:"
    mVolume.value = settings.musicVol

    sVolume = new uiElements.Slider
    sVolume.x = 300
    sVolume.y = 500
    sVolume.width = 200
    sVolume.text = "Sound Volume:"
    sVolume.value = settings.soundVol / 3

    while true
        mVolume.update
        settings.musicVol = mVolume.value
        globals.mus.adjust mVolume.value

        sVolume.update
        settings.soundVol = sVolume.value * 3

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
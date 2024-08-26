
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

    play = new ui.Button
    play.x = 960/3; play.y = 200
    play.text = "PLAY"
    play.init

	settings = new ui.Button
    settings.x = 960/1.5; settings.y = 200
    settings.text = "SETTINGS"
    settings.init

    while true  // (press Control-C to exit)
        yield
        bg.x = bg.image.width*2+((time*-200)%bg.image.width/2*bg.scale)
		car.x =  960/2 + sin(time*0.6)*300
        logo.rotation = sin(time*3) * 2
        // The mouse button is down.  Check each of our buttons, 
        // and do whatever they should do if clicked.
        if play.isClicked then
            // Fade out
	    	display(0).mode = displayMode.solidColor
	    	d = display(0)
			for a in range(5, 255, 5)
			    d.color = color.rgba(0, 0, 0, a)
			    yield
	    	end for
            gfx.clear
			ui.Button.clear
            disp.sprites = []
            play.die
            break
        end if
    end while
end function

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

    play = new ui.Button
    play.x = 960/3; play.y = 200
    play.text = "PLAY"
    play.init

	settings = new ui.Button
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
			ui.Button.clear
            disp.sprites = []
            playerMenu
            return
        else if settings.isClicked then
            optionsMenu
            return
        end if
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
    
    playerRightButton = new ui.Button
    playerRightButton.size = 0
    playerRightButton.x = 960*(1/4)+150; playerRightButton.y = 350
    playerRightButton.text = ">"
    playerRightButton.init

    playerLeftButton = new ui.Button
    playerLeftButton.size = 0
    playerLeftButton.x = 960*(1/4)-150; playerLeftButton.y = 350
    playerLeftButton.text = "<"
    playerLeftButton.init

    enemyRightButton = new ui.Button
    enemyRightButton.size = 0
    enemyRightButton.x = 960*(3/4)+150; enemyRightButton.y = 350
    enemyRightButton.text = ">"
    enemyRightButton.init

    enemyLeftButton = new ui.Button
    enemyLeftButton.size = 0
    enemyLeftButton.x = 960*(3/4)-150; enemyLeftButton.y = 350
    enemyLeftButton.text = "<"
    enemyLeftButton.init

    playerReadyButton = new ui.Button
    playerReadyButton.size = 1
    playerReadyButton.x = 960*(1/4); playerReadyButton.y = 150
    playerReadyButton.text = "READY"
    playerReadyButton.init
    playerReadyButton.ready = false

    enemyReadyButton = new ui.Button
    enemyReadyButton.size = 1
    enemyReadyButton.x = 960*(3/4); enemyReadyButton.y = 150
    enemyReadyButton.text = "READY"
    enemyReadyButton.init
    enemyReadyButton.ready = false
    
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
        end if

        if enemyReadyButton.ready == true and playerReadyButton.ready == true then break

        yield
    end while
    gfx.clear
    ui.Button.clear
    disp.sprites = [player, enemy]

    globals.player.images = playerSprite.images
    globals.enemy.images = enemySprite.images
end function

optionsMenu = function
    gfx.clear
    ui.Button.clear
    bg = new Sprite
    bg.image = images.woodPanel
    bg.y = 320
    bg.x = 960/2
    bg.scale = 4
    disp.sprites.push bg
    
    exit = new ui.Button
    exit.x = 910; exit.y = 590
    exit.text = "X"
    exit.size = 0
    exit.init

    clearAchivements = new ui.Button
    clearAchivements.x = 960*(2/8); clearAchivements.y = 50
    clearAchivements.text = "Clear Achivements"
    clearAchivements.size = 2
    clearAchivements.color = color.rgb(255, 50, 50)
    clearAchivements.pressedColor = color.rgb(200, 0, 0)
    clearAchivements.init

    clearSettings = new ui.Button
    clearSettings.x = 960*(6/8); clearSettings.y = 50
    clearSettings.text = "Clear Settings"
    clearSettings.size = 2
    clearSettings.color = color.rgb(255, 50, 50)
    clearSettings.pressedColor = color.rgb(200, 0, 0)
    clearSettings.init

    mVolume = new ui.Slider
    mVolume.x = 300
    mVolume.y = 550
    mVolume.width = 200
    mVolume.text = "Music Volume:"
    mVolume.value = globals.musicVol

    sVolume = new ui.Slider
    sVolume.x = 300
    sVolume.y = 500
    sVolume.width = 200
    sVolume.text = "Sound Volume:"
    sVolume.value = globals.soundVol / 3

    while true
        mVolume.update
        globals.musicVol = mVolume.value
        globals.mus.adjust mVolume.value

        sVolume.update
        globals.soundVol = sVolume.value * 3

        if exit.isClicked then
            sVolume.die
            mVolume.die
            ui.Button.clear
            gfx.clear
            disp.sprites = [bg]
            updatable.all = []
            mainMenu
            return
        else if clearAchivements.isClicked then
            sVolume.die
            mVolume.die
            ui.Button.clear
            gfx.clear
            disp.sprites = [bg]
            updatable.all = []
            mainMenu
            return
        else if clearSettings.isClicked then
            sVolume.die
            mVolume.die
            ui.Button.clear
            gfx.clear
            disp.sprites = [bg]
            updatable.all = []
            mainMenu
            return
        end if
        yield
    end while

end function
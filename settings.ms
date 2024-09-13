
musicVol = 0.2
soundVol = 2

settingsFilePath = function
	if not file.exists("/usr/save") then
		file.makedir "/usr/save"
	end if
	return "/usr/save/settings.dat"
end function

parse = function(valstr)
    while valstr[0] == " "; valstr = valstr[1:]; end while
    if not valstr then return null
    if valstr[0] == "[" then 
        result = []
        for item in valstr[1:-1].split(",")
            result.push(parse(item))
        end for
        return result
    else 
        num = val(valstr)
        if num isa number and valstr == str(num) then
            return num 
        else
            return valstr.trim("""") 
        end if
    end if
end function

loadSettings = function
    for line in file.readLines(settingsFilePath)
        kv = line.split(":", 2)
        if kv[0] == "MusicVol" then 
            outer.musicVol = parse(kv[1])
        else if kv[0] == "SoundVol" then 
            outer.soundVol = parse(kv[1])
        end if
    end for
end function

saveSettings = function
    data = []
    data.push "MusicVol:" + outer.musicVol
    data.push "SoundVol:" + outer.soundVol
    return file.writeLines(settingsFilePath, data)
end function
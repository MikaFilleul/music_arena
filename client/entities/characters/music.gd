extends AudioStreamPlayer3D

func setMusic(skinId:int):
	var volume = saveSettings._settings
	#volume.audio.son/100*(-24)
	#conversion du volume en décibèles
	self.set_unit_db(volume.audio.musique)

	if volume.audio.musique == 0:
		set_stream_paused(true)
		return

	var musicTracks = {
		1: "res://models/music/dreamy.wav",
		2: "res://models/music/funk.wav",
		3: "res://models/music/celtic.wav",
		4: "res://models/music/reggae.wav",
		5: "res://models/music/rock.wav",
		6: "res://models/music/electro.wav"
	}

	if (skinId > 0 && skinId <= 6):
		set_stream(load(musicTracks[skinId]))
		play()

func setVolume():
	var volume = saveSettings._settings
	#volume.audio.son/100*(-24)
	#conversion du volume en décibèles
	self.set_unit_db(volume.audio.musique)

	if volume.audio.musique == 0:
		set_stream_paused(true)
	else:
		set_stream_paused(false)

extends AudioStreamPlayer3D


# Called when the node enters the scene tree for the first time.
func _ready():
	var volume = saveSettings._settings
	#volume.audio.son/100*(-24)
	#conversion du volume en décibèles
	self.set_unit_db(volume.audio.son)
	
	if volume.audio.son == 0:
		self.queue_free()
	
	var waitTimer = Timer.new()
	waitTimer.set_wait_time(stream.get_length())
	waitTimer.set_one_shot(true)
	self.add_child(waitTimer)
	waitTimer.start()
	yield(waitTimer, "timeout")
	waitTimer.queue_free()
	self.queue_free()




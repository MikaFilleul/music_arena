extends Particles


func _ready():
	self.emitting = true
	var waitTimer = Timer.new()
	waitTimer.set_wait_time(2)
	waitTimer.set_one_shot(true)
	self.add_child(waitTimer)
	waitTimer.start()
	yield(waitTimer, "timeout")
	waitTimer.queue_free()
	self.queue_free()

extends MeshInstance


var initialTr:Vector3 = self.translation
var falling:bool = false
const FACTOR:float = 9.8
const NETHER:int = -75
const BACK:float = -10.0

func _physics_process(delta):
	if (falling):
		var fallVelocity = delta/FACTOR
		self.translation = self.translation.linear_interpolate(Vector3(BACK,NETHER,initialTr.z),fallVelocity)
		if (self.translation.y < NETHER+10):
			self.queue_free()

func startFalling():
	falling = true

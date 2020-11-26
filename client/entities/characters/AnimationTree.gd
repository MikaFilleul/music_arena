extends AnimationTree

var startBlendValue:float = -1
var endBlendValue:float = -1
var time:float = 1
const SPEED:int = 7
var model:Node

# VFX
var dust:Particles
var jump:Resource
var punch:Resource
var kick:Resource
var kickUp:Resource
var kickDown:Resource
var impact:Resource
var impactBig:Resource

# SFX
var critSfx:Resource
var hit1Sfx:Resource
var hit2Sfx:Resource
var jumpSfx:Resource
var kick1Sfx:Resource
var kick2Sfx:Resource
var punchSfx:Resource

func _ready():
	set("parameters/Loops/blend_amount",0)
	model = get_node("../Model")
	dust = get_node("../Model/Dust")
	jump = preload("res://entities/vfx/Jump.tscn")
	punch = preload("res://entities/vfx/Punch.tscn")
	kick = preload("res://entities/vfx/Kick.tscn")
	kickUp = preload("res://entities/vfx/KickUp.tscn")
	kickDown = preload("res://entities/vfx/KickDown.tscn")
	impact = preload("res://entities/vfx/Impact.tscn")
	impactBig = preload("res://entities/vfx/ImpactBig.tscn")
	critSfx = preload("res://entities/sfx/critSfx.tscn")
	hit1Sfx = preload("res://entities/sfx/hit1Sfx.tscn")
	hit2Sfx = preload("res://entities/sfx/hit2Sfx.tscn")
	jumpSfx = preload("res://entities/sfx/jumpSfx.tscn")
	kick1Sfx = preload("res://entities/sfx/kick1Sfx.tscn")
	kick2Sfx = preload("res://entities/sfx/kick1Sfx.tscn")
	punchSfx = preload("res://entities/sfx/punchSfx.tscn")

# Interpolate animations
func _process(delta):
	if time < 1:
		time += delta * SPEED
	if time > 1:
		time = 1
	startBlendValue = startBlendValue + (endBlendValue - startBlendValue) * time
	
func playAnimation(animationType):
	match animationType:
		# Controlled Fall
		-1:
			endBlendValue = -1
			if startBlendValue != endBlendValue:
				time = 0
			set("parameters/Loops/blend_amount", startBlendValue)
			dust.emitting = false
		# Idle
		0:
			endBlendValue = 0
			if startBlendValue != endBlendValue:
				time = 0
			set("parameters/Loops/blend_amount", startBlendValue)
			dust.emitting = false
		# Run
		1:
			endBlendValue = 1
			if startBlendValue != endBlendValue:
				time = 0
			set("parameters/Loops/blend_amount", startBlendValue)
			dust.emitting = true
		# Jump
		2:
			startBlendValue = -1
			set("parameters/Loops/blend_amount",-1)
			set("parameters/OS Jump Up/active",true)
			dust.emitting = false
			var particle = jump.instance()
			model.add_child(particle)
			var sound = jumpSfx.instance()
			model.add_child(sound)
		# Punch 1
		3:
			set("parameters/OS Punch 1/active",true)
			dust.emitting = false
			var particle = punch.instance()
			model.add_child(particle)
			var sound = punchSfx.instance()
			model.add_child(sound)
		# Punch 2
		4:
			set("parameters/OS Punch 2/active",true)
			dust.emitting = false
			var particle = punch.instance()
			model.add_child(particle)
			var sound = punchSfx.instance()
			model.add_child(sound)
		# Kick 1
		5:
			set("parameters/OS Kick 1/active",true)
			dust.emitting = false
			var particle = kick.instance()
			model.add_child(particle)
			var sound = kick1Sfx.instance()
			model.add_child(sound)
		# Kick 2
		6:
			set("parameters/OS Kick 2/active",true)
			dust.emitting = false
			var particle = kick.instance()
			model.add_child(particle)
			var sound = kick2Sfx.instance()
			model.add_child(sound)
		# Kick Up
		7:
			set("parameters/OS Kick Up/active",true)
			dust.emitting = false
			var particle = kickUp.instance()
			model.add_child(particle)
			var sound = kick2Sfx.instance()
			model.add_child(sound)
		# Jump Kick Side
		8:
			set("parameters/OS Jump Kick Side/active",true)
			dust.emitting = false
			var particle = kick.instance()
			model.add_child(particle)
			var sound = kick1Sfx.instance()
			model.add_child(sound)
		# Jump Kick Up
		9:
			set("parameters/OS Jump Kick Up/active",true)
			dust.emitting = false
			var particle = kickUp.instance()
			model.add_child(particle)
			var sound = kick2Sfx.instance()
			model.add_child(sound)
		# Jump Kick Down
		10:
			set("parameters/OS Jump Kick Down/active",true)
			dust.emitting = false
			var particle = kickDown.instance()
			model.add_child(particle)
			var sound = kick1Sfx.instance()
			model.add_child(sound)
		# Turn
		11:
			set("parameters/OS Turn/active",true)
			dust.emitting = false
		# Impact 1
		12:
			set("parameters/OS Impact 1/active",true)
			dust.emitting = false
			var particle = impact.instance()
			model.add_child(particle)
			var sound = hit1Sfx.instance()
			model.add_child(sound)
		# Impact 2
		13:
			set("parameters/OS Impact 2/active",true)
			dust.emitting = false
			var particle = impact.instance()
			model.add_child(particle)
			var sound = hit2Sfx.instance()
			model.add_child(sound)
		# Impact Jump
		14:
			set("parameters/OS Impact Jump/active",true)
			dust.emitting = false
			var particle = impact.instance()
			model.add_child(particle)
			var sound = hit1Sfx.instance()
			model.add_child(sound)
		# Big Impact
		15:
			set("parameters/OS Big Impact/active",true)
			dust.emitting = false
			var particle = impactBig.instance()
			model.add_child(particle)
			var sound = critSfx.instance()
			model.add_child(sound)

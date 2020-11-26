extends KinematicBody

var pseudo:String = "anonymous"

var currentDirection:int = 1
var currentRotation:float = 0
var model
const SPEED:int = 3
const ANIM_TURN:int = 11

var kills = 0


func _ready():
	model = get_node("Model")
	gamestate.players[int(self.name)]["status"] = "alive"


func _process(delta):
	model.rotation = model.rotation.linear_interpolate(Vector3(0,currentRotation,0),delta*SPEED)


# Set pseudo
func setPseudo(pseudoString:String):
	self.pseudo = pseudoString

# Set character skin
func setSkin(skinId:int):
	var skins = {
		0: "res://models/skins/default.tres",
		1: "res://models/skins/lullaby.tres",
		2: "res://models/skins/disco.tres",
		3: "res://models/skins/angela.tres",
		4: "res://models/skins/reggae.tres",
		5: "res://models/skins/metal.tres",
		6: "res://models/skins/electro.tres"
	}

	if (skinId >= 0 && skinId <= 6):
		var mesh = get_node("Model/Armature/Mesh")
		mesh.set_mesh(load(skins[skinId]))


# Turn character to the specified direction (-1,1)
func turn(direction:int):
	# Trigger the turn-around animation
	if (currentDirection != direction):
		get_node("AnimationTree").playAnimation(ANIM_TURN)

	# Update the direction of the player
	if (direction == 1):	# Left
		currentDirection = direction
		currentRotation = 0
		model.set_rotation(Vector3())
	else:					# Right
		currentDirection = direction
		currentRotation = -PI
		model.set_rotation(Vector3(0,-PI,0))


# Rotate character on hit
func rotatePlayerOnHit(angle:float):
	if (currentRotation == 0):
		model.rotation = Vector3(0,currentRotation,angle-PI)
	else:
		model.rotation = Vector3(0,currentRotation,-angle)


# Update the health displayed
func hurt(hpNow:int):
	get_node("Labels/Hp").update_printed_hp(hpNow)
	if str(get_tree().get_network_unique_id()) == str ( get_node(".").get_name()) :  
		get_node("../interface").displayDamages(hpNow)


# Feedback when killed
func die(killerId:int):
	print(str(killerId) + " killed " + self.name)
	gamestate.players[int(self.name)]["status"] = "dead"
	gamestate.endGameStats["rank"] -= 1

	# Hide the killed player (NB: the client is only about inputs and display)
	#self.set_visible(false)


# Play the specified animation
func getAnimationTypePlay(animationType:int):
	get_node("AnimationTree").playAnimation(animationType)

func giveKill(killsNum:int):
	self.kills = killsNum
	get_node("../interface").displayNbKills(self.kills)
	if str(get_tree().get_network_unique_id()) == str(self.name):
		gamestate.endGameStats["kills"] = killsNum

extends Node


# Movement vars
var movementInput:int = 0
var jumpId:int = 0              # Distinguish 2 different jumps
var mouseX:int = 0							# Mouse X percentage
var mouseY:int = 0							# Mouse Y percentage
var itemInput:bool = false

# General attacks ID
enum {
	NONE=0,
	PUNCH=1,
	KICK=2
}

# Game vars
const MINUTE:int = 60
var timeRemaining:int
var timeToTarget:float = 0

# Zones
const ZONESIZE:float = 0.4
var safeZone:Node
var killArea:Node
var initialSize:Vector3
var initialTr:Vector3
var zoning:bool = false
var centerX:float = 0
var centerY:float = 0

# Item vars
var itemsType = ["beer","hot_dog"]


# Initialize the game scene, players, camera and display
func _ready():
	var player_scene:PackedScene = preload("res://entities/characters/player.tscn")
	var loadingScreen = $loadingScreen

	#Next evey player will spa every other player including the server's own client! Try to move this to server only
	for peer_id in gamestate.players:
		var player:Node = player_scene.instance()

		player.set_name(str(peer_id))
		player.setPseudo(gamestate.players[peer_id]["pseudo"])
		player.setSkin(gamestate.players[peer_id]["skin"])
		get_node("/root/game/").add_child(player)

	var playerArrow:Node = preload("res://entities/characters/playerArrow.tscn").instance()
	var playerCamera:Node =	preload("res://entities/characters/camera.tscn").instance()
	
	get_node(gamestate.GAMEPATH+str(get_tree().get_network_unique_id())+"/Music").setMusic(gamestate.players[get_tree().get_network_unique_id()]["skin"])
	get_node(gamestate.GAMEPATH+str(get_tree().get_network_unique_id())).add_child(playerArrow)
	get_node(gamestate.GAMEPATH+str(get_tree().get_network_unique_id())).add_child(playerCamera)

	init(gamestate.maxPlayers)

	safeZone = get_node("killingFallArea/DangerZone/SafeZone")
	killArea = get_node("killingFallArea")

	initialSize = safeZone.scale
	initialTr = killArea.translation
	
	gamestate.clientGameLoaded()
	
	print("prepause true")
	get_tree().set_pause(true)
	print("postpause true")
	yield(gamestate, "gameFullyLoaded")
	loadingScreen.visible = false
	print("gameFullyLoaded")
	
	get_tree().set_pause(false)


### NEEDS REFACTORING
# Sends the input at every tick of the engine !!!
func _physics_process(delta):
	getPlayerInput()

	if (zoning):
		safeZone.scale = initialSize.linear_interpolate(Vector3(ZONESIZE,ZONESIZE,initialSize.z),timeToTarget)
		killArea.translation = initialTr.linear_interpolate(Vector3(centerX,centerY,initialTr.z),timeToTarget)

		if (timeToTarget < 1):
			timeToTarget += delta/timeRemaining

# Get the inputs of the player
func getPlayerInput():
	movementInput = 0
	itemInput = false
	var attackStateInput:int = NONE
	var vpSize:Vector2 = get_viewport().size
	var mousePosition:Vector2 = get_viewport().get_mouse_position()

	# Movement vars
	if Input.is_action_pressed("movementLeft"):
		movementInput -= 1
	if Input.is_action_pressed("movementRight"):
		movementInput += 1

	# Jump var (using id prevents to process several times the same resent data))
	if Input.is_action_just_pressed("movementJump"):
		jumpId += 1

	if Input.is_action_just_pressed("itemInput"):
		itemInput = true

	if Input.is_action_pressed("primaryAttack"):
		attackStateInput = PUNCH
		mouseX = int(mousePosition.x/vpSize.x * 100) - 50
		mouseY = int(mousePosition.y/vpSize.y * 100) - 50

	elif Input.is_action_pressed("secondaryAttack"):
		attackStateInput = KICK
		mouseX = int(mousePosition.x/vpSize.x * 100) - 50
		mouseY = int(mousePosition.y/vpSize.y * 100) - 50

	# Sent without safety resend
	network.sendInputs(movementInput, jumpId, attackStateInput, mouseX, mouseY, itemInput)


func init(numPlayers):
	match(numPlayers):
		2:
			timeRemaining = 2 * MINUTE
		4:
			timeRemaining = 4 * MINUTE
		8:
			timeRemaining = 6 * MINUTE
		16:
			timeRemaining = 8 * MINUTE
		32:
			timeRemaining = 10 * MINUTE

func startZoning(xVal:float, yVal:float):
	centerX = xVal
	centerY = yVal
	zoning = true
	print("Starting to Zone")


func addItem(itemId,itemType,position):
	var itemScene = load("res://entities/items/"+itemsType[itemType]+".tscn")
	var item = itemScene.instance()
	item.set_name("item"+str(itemId))
	item.translate(position)
	get_node(gamestate.GAMEPATH+"itemCollection").add_child(item)

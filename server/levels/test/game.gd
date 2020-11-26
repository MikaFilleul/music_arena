extends Node

# Game vars
const MINUTE:int = 60
var timeRemaining:int
var timeToTarget:float = 0

# Zones
const WAITZONE:int = 10
const ZONESIZE:float = 0.4
const ISLANDSIZE:float = 0.15
const XMIN:int = -37
const XMAX:int = 44
const YMIN:int = -18
const YMAX:int = 17

var safeShape:Node
var safeZone:Node
var islandsShape:Node
var killArea:Node
var islandArea:Node
var initialShapeSize:Vector3
var initialZoneSize:Vector3
var initialIslandSize:Vector3
var initialAreaTr:Vector3
var initialIAreaTr:Vector3
var zoning:bool = false
var centerX:float = 0
var centerY:float = 0

# item vars
var itemTimer = null

const MAX_ITEMS = 3
var nbItemTotal:int = 0
var item_delay = 30
var typeItems = ["beer","hot_dog"]
signal deleteItem


func _ready():

	itemTimer = Timer.new()
	itemTimer.set_one_shot(false)
	itemTimer.set_wait_time(item_delay)
	itemTimer.connect("timeout",self,"_initNewItem")
	get_node(gamestate.GAMEPATH).add_child(itemTimer)

	init(gamestate.maxClients)

	safeShape = get_node("killingFallArea/SafeShape")
	safeZone = get_node("killingFallArea/DangerZone/SafeZone")
	islandsShape = get_node("islandFallArea/islandsShape")
	killArea = get_node("killingFallArea")
	islandArea = get_node("islandFallArea")

	initialShapeSize = safeShape.scale
	initialZoneSize = safeZone.scale
	initialIslandSize = islandsShape.scale
	initialAreaTr = killArea.translation
	initialIAreaTr = islandArea.translation
	
	yield(gamestate, "readyToProcess")

	waitZoning()


func _physics_process(delta):
	if (zoning):
		
		# Check for the endgame conditions
		if (gamestate.registeredClients.size()==1):
			gamestate.endGame()
		
		safeShape.scale =	initialShapeSize.linear_interpolate(Vector3(ZONESIZE,ZONESIZE,initialShapeSize.z),timeToTarget)
		safeZone.scale = initialZoneSize.linear_interpolate(Vector3(ZONESIZE,ZONESIZE,initialZoneSize.z),timeToTarget)
		islandsShape.scale = initialIslandSize.linear_interpolate(Vector3(ISLANDSIZE,ISLANDSIZE,initialIslandSize.z),timeToTarget)
		killArea.translation =	initialAreaTr.linear_interpolate(Vector3(centerX,centerY,initialAreaTr.z),timeToTarget)
		islandArea.translation =	initialIAreaTr.linear_interpolate(Vector3(centerX,centerY,initialIAreaTr.z),timeToTarget)

		if (timeToTarget < 1):
			timeToTarget += delta/timeRemaining


# Signal: player out of the zone
func _on_killingFallArea_body_exited(body:PhysicsBody):
	# Check if the body is a player
	if body.get_collision_layer_bit(gamestate.Layer.PLAYER):
		body.die()

func _on_islandFallArea_body_exited(body:Node):
	if body.get_collision_layer_bit(gamestate.Layer.ENVIRONMENT):
		body.get_parent().startFalling()

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

func waitZoning():
	var waitTimer = Timer.new()
	waitTimer.set_wait_time(WAITZONE)
	waitTimer.set_one_shot(true)
	self.add_child(waitTimer)
	waitTimer.start()
	yield(waitTimer, "timeout")
	waitTimer.queue_free()
	randomize()
	centerX = rand_range(XMIN, XMAX)
	centerY = rand_range(YMIN, YMAX)
	broadcastZoning(centerX, centerY)
	zoning = true

func broadcastZoning(xVal:float, yVal:float):
	gamestate.broadcastZoning(xVal,yVal)

func _initNewItem():
	emit_signal("deleteItem")
	spawnInitItem()

# Create new item in the game
func spawnInitItem():
	var listAvailableItem= []
	# Create a list of available spawn points
	for i in range(gamestate.MAX_SPAWN_POINT):
		listAvailableItem.append(i)

	gamestate.rng.randomize()

	for _item_counter in range(MAX_ITEMS):
		nbItemTotal+=1
		var typeItem = gamestate.rng.randi_range(0,len(typeItems)-1)
		var itemScene = load("res://entities/items/"+typeItems[typeItem]+".tscn")
		var newitemScene = itemScene.instance()
		var i=gamestate.rng.randi_range(0,len(listAvailableItem)-1)
		var position = get_node(gamestate.GAMEPATH+"spawnCollection/spawn"+str(listAvailableItem[i]+1)).get_translation()
		newitemScene.set_name("item"+str(nbItemTotal))
		get_node(gamestate.GAMEPATH+"itemCollection/").add_child(newitemScene)
		newitemScene.id = nbItemTotal
		newitemScene.typeItem = typeItem
		self.connect("deleteItem",newitemScene,"on_timeout_complete")
		newitemScene.translate(position)
		listAvailableItem.remove(i)
		gamestate.broadcastNewItem(nbItemTotal,typeItem,position)

	itemTimer.start()

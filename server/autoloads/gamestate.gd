extends Node

var serverId:int
var serverPw:int

var maestroIp:String
var maestroPort:int

var maxClients:int
var awaitedClients:Array = []
var registeredClients:Array = []
var missingClients:Array = []

# Dictionary with
# { playerId: {
# 	pseudo: ...
# 	skin: ...
# }}
var players:Dictionary = {}

const START_UP_DELAY:int = 5
signal serverValidation

const LOADING_DELAY:float = 60.0
var clientsLoaded:Timer
signal readyToProcess

const GAMEPATH:String = "/root/game/"
enum Layer {
	ENVIRONMENT = 0,
	PLAYER = 1
}

const MAX_SPAWN_POINT = 70

var rng = RandomNumberGenerator.new()

signal finishLoading

func _ready():

	# Get the arguments passed by the forker script
	serverId = int(OS.get_cmdline_args()[0].split('=')[1])
	serverPw = int(OS.get_cmdline_args()[1].split('=')[1])

	maestroIp = OS.get_cmdline_args()[2].split('=')[1]
	maestroPort = int(OS.get_cmdline_args()[3].split('=')[1])

	# Prevent an rpc call while the network node has not been fully charged
	yield(network, "networkReady")

	# Authentication call to the maestro
	network.newServerForked(serverId, serverPw)


#################################################################
### SERVER-MAESTRO FUNCTIONS


# --- Called by network ---
# Maestro successfuly joined and server authenticated
func serverInitRequest(maxClients:int):
	self.maxClients = maxClients
	print("S:", gamestate.serverId, " initialized for ", maxClients, " players game")
	network.serverInitialized()


# --- Called by network ---
# Wait for the connection of the specified client
func waitClientRequest(clientNetworkId:int, pseudo:String, skinId:int):
	# General case
	if registeredClients.size()+awaitedClients.size()<self.maxClients:
		awaitedClients.append(clientNetworkId)
		players[clientNetworkId] = {
			"pseudo": pseudo,
			"skin": skinId
		}
		print("S:", serverId, " is now waiting for a player (rpc_id:", clientNetworkId, ")")
		network.waitClientAnswer(clientNetworkId, true)

	# Size exceeded, but not supposed to happen
	else:
		print("S:", serverId, " has exceeded its player capacity: not supposed to happen !!!")
		network.waitClientAnswer(clientNetworkId, false, "-> Server size exceeded")


# --- Called by network ---
# Client lost by the maestro => clean it from the server he possibly was in
func clientLost(clientNetworkId:int):
	if awaitedClients.has(clientNetworkId):
		print("S:", serverId, " Client ", clientNetworkId, " was purged from the awaited clients")
		awaitedClients.erase(clientNetworkId)
		players.erase(clientNetworkId)
	elif registeredClients.has(clientNetworkId):
		print("S:", serverId, " Client ", clientNetworkId, " was purged from the registered clients")
		registeredClients.erase(clientNetworkId)
		players.erase(clientNetworkId)

###
#################################################################

#################################################################
### SERVER-CLIENT FUNCTIONS


# --- Called by network ---
# A client wants to join the server
func joinServerRequest(clientNetworkId):
	if !awaitedClients.has(clientNetworkId):
		network.joinServerAnswer(clientNetworkId, false, "-> The server was not waiting for you !")
		return

	print("S:", serverId, " was joined by a player (rpc_id:", clientNetworkId, ")")

	# Update the lists of clients
	registeredClients.append(clientNetworkId)
	awaitedClients.erase(clientNetworkId)

	# Inform the client and the maestro
	network.joinServerAnswer(clientNetworkId, true)
	network.clientJoinedServer(clientNetworkId)

	# TODO: What if there are still awaited players when the registered clients array is full ?
	# => Not supposed to happen

	# WHen the server is full, the game can begin
	if registeredClients.size()==maxClients:
		readyToPlay()


# --- Called by network ---
# A client wants to leave the server
func leaveServerRequest(clientNetworkId:int):
	# The client was awaited
	if awaitedClients.has(clientNetworkId):
		awaitedClients.erase(clientNetworkId)
		print("S:", serverId, " peer ", clientNetworkId, " erased for the awaited clients")

	# The client was registered
	elif registeredClients.has(clientNetworkId):
		registeredClients.erase(clientNetworkId)
		players.erase(clientNetworkId)
		print("S:", serverId, " peer ", clientNetworkId, " erased for the registered clients")

	# The client trying to leave was not there in the first place !
	# Not supposed to happen
	else:
		print("S:", serverId, " Error, peer ", clientNetworkId, " is not recognized is the game server")


###
#################################################################

#################################################################
### GAME MANAGEMENT FUNCTIONS FUNCTIONS


# Server full, try to start the game
func readyToPlay():
	print("S:", serverId, " is full, game will start in ", START_UP_DELAY)

	# Alert the clients
	for clientNetworkId in registeredClients:
		network.serverAlert(clientNetworkId, "The game is about to start")

	# Timer
	yield(get_tree().create_timer(START_UP_DELAY), "timeout")

	# The game can still start
	if registeredClients.size()==self.maxClients:
		startGame()
	# A client left, we can't start the game
	else:
		for clientNetworkId in registeredClients:
			network.serverAlert(clientNetworkId, "A player left, starting canceled ...")


# --- Called by network ---
# Server validation received
func serverValidation():
	emit_signal("serverValidation")


# Create a new player and place it on a random spawn point
func spawnPlayer():
	var playerScene = preload("res://entities/characters/player.tscn")

	var listAvailableSpawn = []
	# Create a list of available spawn points
	for i in range(MAX_SPAWN_POINT):
		listAvailableSpawn.append(i)

	rng.randomize()

	# Attribute a random spawn point
	for peer_id in registeredClients:
		var newPlayer = playerScene.instance()
		newPlayer.set_name(str(peer_id))
		get_node(GAMEPATH).add_child(newPlayer)
		var i=rng.randi_range(0,len(listAvailableSpawn)-1)
		var spawnPosition = get_node(GAMEPATH+"spawnCollection/spawn"+str(listAvailableSpawn[i]+1)).get_translation()
		newPlayer.translate(spawnPosition)
		listAvailableSpawn.remove(i)

#Wait loading timeout
func timerLoadingDelay():
	yield(clientsLoaded,"timeout")
	emit_signal("finishLoading")


# Wait for server validation and start the game
# => TODO: server validation timeout ?
func startGame() -> void:
	network.gameHasStarted()
	yield(self, "serverValidation")
	missingClients = registeredClients.duplicate()

	clientsLoaded = Timer.new()
	add_child(clientsLoaded)

	clientsLoaded.set_wait_time(LOADING_DELAY)
	clientsLoaded.start()

	# Instancing the map and adding it to the scene tree
	var game:Object = preload("res://levels/test/game.tscn").instance()
	get_tree().get_root().add_child(game)

	spawnPlayer()
	timerLoadingDelay()

	# Broadcast the beginning of the game to the clients loaded
	for clientNetworkId in registeredClients:
		network.loadGame(clientNetworkId, players)

	while(len(missingClients)!=0 && clientsLoaded.get_time_left()!=0):
		yield(self,"finishLoading")

	print("loading timeout")
	emit_signal("readyToProcess")

	# Screw the latecomers
	for clientNetworkId in missingClients:
		kickPlayer(clientNetworkId)

	for clientNetworkId in registeredClients:
		network.startGame(clientNetworkId)

	game.spawnInitItem()

	print("S:", serverId, "Game started with peers ", registeredClients)


func clientGameLoaded(clientId:int):
	var index:int = missingClients.find(clientId)
	if index==-1:
		print("S:", self.serverId, " Client loaded, but unknown client tho (WTF)")
		return

	missingClients.erase(clientId)
	emit_signal("finishLoading")


# Kick a client from the game with a message
# TODO: Use different vars for the endgame screen
func kickPlayer(playerId:int):
	network.kickPlayer(playerId, "You lost ...")
	registeredClients.erase(playerId)
	players.erase(playerId)


# Inform the winner and the maestro that the game has ended, and then destroy the server
func endGame():
	network.kickPlayer(registeredClients[0], "You won !!!")
	network.gameHasEnded(registeredClients[0])

	registeredClients.clear()
	players.clear()

	print("S:", serverId, " Game has ended, self-destruction initiated !")

	get_node("/root/").queue_free()
	get_tree().quit()


###
#################################################################

#################################################################
### RPC MOCK: NEED TO BE REPLACED BY THE NETWORK TEAMS WORK


func sendPlayerInputs(senderId:int, movementInput:int, jumpId:int, attackStateInput:int, mouseX:int, mouseY:int, itemInput:bool):
	if gamestate.registeredClients.has(senderId):
		gamestate.get_node("/root/game/"+str(senderId)).getPlayerInputs(movementInput, jumpId, attackStateInput, mouseX, mouseY, itemInput)

func broadcastMovement(playerId:int, playerPosition:Vector3):
	for networkId in registeredClients:
		network.sendPlayerMovement(networkId, playerId, playerPosition)

func broadcastHp(playerId:int, hp:int):
	for networkId in registeredClients:
		network.hurtPlayer(networkId, playerId, hp)

func broadcastTurn(playerId:int, direction:int):
	for networkId in registeredClients:
		network.turnPlayer(networkId, playerId, direction)

func broadcastRotateOnHit(playerId:int, angle:float):
	for networkId in registeredClients:
		network.rotatePlayerOnHit(networkId, playerId, angle)

func broadcastAnimation(playerId:int, animationType:int):
	for networkId in registeredClients:
		network.animatePlayer(networkId, playerId, animationType)

func broadcastKill(playerId:int, kills:int):
	for networkId in registeredClients:
		network.updateKills(networkId, playerId, kills)

func killPlayer(playerId:int, killerId:int):
	for networkId in registeredClients:
		network.killPlayer(networkId, playerId, killerId)
	kickPlayer(playerId)

func broadcastNewItem(itemId:int, itemType:int, position:Vector3):
	for networkId in registeredClients:
		network.setNewItem(networkId, itemId, itemType, position)

func broadcastDeleteItem(itemId:int):
	for networkId in registeredClients:
		network.deleteItem(networkId, itemId)
###
#################################################################


func broadcastZoning(centerX:float, centerY:float):
	for networkId in registeredClients:
		network.startZoning(networkId, centerX, centerY)

func broadcastFalling(island:String):
	for networkId in registeredClients:
		network.startFalling(networkId, island)

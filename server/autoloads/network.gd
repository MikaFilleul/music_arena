extends Node

var serverPeer:NetworkedMultiplayerENet

signal networkReady

func _ready():
	# Connect rpc signals
	get_tree().connect("connected_to_server", self, "_connectedToMaestro")

	# Server init
	serverPeer = NetworkedMultiplayerENet.new()
	serverPeer.create_client(gamestate.maestroIp,gamestate.maestroPort)
	get_tree().set_network_peer(serverPeer)


#################################################################
### NETWORK SIGNALS


func _connectedToMaestro():
	emit_signal("networkReady")
	print("S:", gamestate.serverId, " created, waiting for authentification")


#################################################################
### SERVER-MAESTRO FUNCTIONS


# Sent on init to be authentify by the maestro
func newServerForked(serverId:int, serverPw:int):
	rpc_id(1, "newServerForked", serverId, serverPw)


# Receive the rest of the informations needed and answer
puppet func serverInitRequest(maxPlayers:int):
	gamestate.serverInitRequest(maxPlayers)

func serverInitialized():
	rpc_id(1, "serverInitialized")


# Receive a client Id that will try to connect and answer
puppet func waitClientRequest(clientNetworkId:int, pseudo:String, skinId:int):
	gamestate.waitClientRequest(clientNetworkId, pseudo, skinId)

func waitClientAnswer(clientNetworkId:int, answer:bool, error:String=""):
	rpc_id(1, "waitClientAnswer", clientNetworkId, answer, error)


# Inform the maestro of the successful connection of the specified client (which ha was ordered to wait for)
func clientJoinedServer(clientNetworkId:int):
	rpc_id(1, "clientJoinedServer", clientNetworkId)


puppet func clientLost(clientNetworkId:int):
	gamestate.clientLost(clientNetworkId)


# Send the info of the game starting to the maestro for sync and its answer
func gameHasStarted():
	rpc_id(1, "gameHasStarted")

puppet func serverValidation():
	gamestate.serverValidation()


# Send the info of the game ending to the maestro
func gameHasEnded(clientNetworkId:int):
	rpc_id(1, "gameHasEnded", clientNetworkId)


#################################################################
### SERVER-CLIENT FUNCTIONS


# Received when a client try to connect to the server (and answer)
# !!! Technically, it's peer2peer !!!
remote func joinServerRequest():
	gamestate.joinServerRequest(get_tree().get_rpc_sender_id())

func joinServerAnswer(clientNetworkId:int, answer:bool, error:String=""):
	rpc_id(clientNetworkId, "joinServerAnswer", answer, error)


# Received when a player ask to leave the server
remote func leaveServerRequest():
	gamestate.leaveServerRequest(get_tree().get_rpc_sender_id())


# Send an alert in the lobby of client (future chat ?)
func serverAlert(clientNetworkId:int, text:String):
	rpc_id(clientNetworkId, "serverAlert", text)


# Load the game in the client app
# => will probably change after the network merge !!!
func loadGame(clientNetworkId:int, players:Dictionary):
	rpc_id(clientNetworkId, "loadGame", players)


func startGame(clientNetworkId:int):
	rpc_id(clientNetworkId, "startGame")


remote func clientGameLoaded():
	gamestate.clientGameLoaded(get_tree().get_rpc_sender_id())


# Make the client leave the game with a message displayed
# => used to inform the client when he lose/win
func kickPlayer(clientId:int, message:String=""):
	rpc_id(clientId, "kickedFromServer", message)


#################################################################
### OLD STUFF (OUTDATED)
### => WILL BE CHANGED ACCORDING TO THE NETWORK TEAMS WORK


remote func sendPlayerInputs(movementInput:int, jumpId:int, attackStateInput:int, mouseX:int, mouseY:int, itemInput:bool):
	# Get the input from the client and send it to the matching remote player
	var senderId:int = get_tree().get_rpc_sender_id()
	gamestate.sendPlayerInputs(senderId, movementInput, jumpId, attackStateInput, mouseX, mouseY, itemInput)

func sendPlayerMovement(networkId:int, playerId:int, playerPosition:Vector3):
	rpc_unreliable_id(networkId, "setPlayerPosition", playerId, playerPosition)

func hurtPlayer(networkId:int, playerId:int, hpNow:int):
	rpc_unreliable_id(networkId, "hurtPlayer", playerId, hpNow)

func animatePlayer(networkId:int, playerId:int, animationType:int):
	rpc_unreliable_id(networkId, "animatePlayer", playerId, animationType)

func turnPlayer(networkId:int, playerId:int, direction:int):
	rpc_unreliable_id(networkId, "turnPlayer", playerId, direction)

func rotatePlayerOnHit(networkId:int, playerId:int, angle:float):
	rpc_unreliable_id(networkId, "rotatePlayerOnHit", playerId, angle)

func updateKills(networkId:int, playerId:int, kills:int):
	rpc_id(networkId, "updateKills", playerId, kills)

func killPlayer(networkId:int, playerId:int, killerId:int):
	rpc_id(networkId, "killPlayer", playerId, killerId)

func startZoning(networkId:int, centerX:float, centerY:float):
	rpc_id(networkId, "startZoning", centerX, centerY)

func startFalling(networkId:int, island:String):
	rpc_id(networkId, "startFalling", island)

func setNewItem(networkId:int, itemId:int, itemType:int, position:Vector3):
	rpc_unreliable_id(networkId, "setNewItem", itemId, itemType, position)

func deleteItem(networkId:int, itemId:int):
	rpc_unreliable_id(networkId, "deleteItem", itemId)

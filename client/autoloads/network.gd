extends Node

var clientPeer:NetworkedMultiplayerENet

var login:String
var pw:String

var maestroIp:String = "91.121.81.74"#"127.0.0.1"
var maestroPort:int = 10001

func _ready():
	get_tree().connect("connected_to_server", self, "_connectionAchieved")
	get_tree().connect("connection_failed", self, "_connectionFailed")
	get_tree().connect("server_disconnected", self, "_playerDisconnected")

	# If a port is specified, use it
	if OS.get_cmdline_args().size() == 1:
		maestroPort = int(OS.get_cmdline_args()[0].split('=')[1])


#################################################################
### NETWORK SIGNALS


func _connectionAchieved():
	match gamestate.isPlaying:
		gamestate.PLAYING:
			rpc_id(1, "joinServerRequest", login, pw)

		gamestate.WAS_PLAYING:
			rpc_id(1, "logbackRequest", login, pw)

		gamestate.NOT_PLAYING:
			rpc_id(1, "loginRequest", login, pw)


func _connectionFailed():
	gamestate.connectionFailure()


func _playerDisconnected():
	gamestate.serverFailure()


#################################################################

#################################################################
### CLIENT-MAESTRO FUNCTIONS


# Login request to the maestro
func loginRequest(login:String, pw:String):
	clientPeer = NetworkedMultiplayerENet.new()
	clientPeer.create_client(maestroIp, maestroPort)
	get_tree().set_network_peer(clientPeer)

	self.login=login
	self.pw=pw

puppet func loginAnswer(answer:bool, error:String):
	gamestate.loginAnswer(answer, error)


# Join request to the maestro
func joinGameRequest(maxPlayers:int, pseudo:String, skinId:int):
	rpc_id(1, "joinGameRequest", maxPlayers, pseudo, skinId)

puppet func joinGameAnswer(serverNetworkId:int, answer:bool, error:String):
	gamestate.joinGameAnswer(serverNetworkId, answer, error)


# TODO: Initialize a team with friend before the matchmaking
func createPartyRequest():
	pass

puppet func createPartyAnswer():
	pass


# TODO: Begin the matchmaking with the friends
func startMatchmakingRequest():
	pass

puppet func startMatchmakingAnswer():
	pass


# TODO: Join a team to play with friends
# => Use a party ID
func joinPartyRequest():
	pass

puppet func joinPartyAnswer():
	pass


# Ask the maestro to leave the game server the client is currently connected
func leaveServer():
	rpc_id(1, "leaveServer")


#################################################################

#################################################################
### CLIENT-SERVER FUNCTIONS


func joinServerRequest(serverId:int):
	rpc_id(serverId, "joinServerRequest")

remote func joinServerAnswer(answer:bool, error:String):
	if get_tree().get_rpc_sender_id()==gamestate.serverNetworkId:
		gamestate.joinServerAnswer(answer, error)


remote func serverAlert(text:String):
	if get_tree().get_rpc_sender_id()==gamestate.serverNetworkId:
		gamestate.serverAlert(text)


remote func loadGame(players:Dictionary):
	if get_tree().get_rpc_sender_id()==gamestate.serverNetworkId:
		gamestate.loadGame(players)


remote func startGame():
	if get_tree().get_rpc_sender_id()==gamestate.serverNetworkId:
		gamestate.startGame()


func clientGameLoaded(serverId:int):
	rpc_id(serverId, "clientGameLoaded")

#################################################################
### !!! THIS SET OF FUNCTIONS HAS TO BE UPDATED ACCORDINGLY TO THE MAIN NETWORK TEAM WORK !!!
### (still rpc there for testing purpose)


func sendInputs(movementInput, jumpId, attackStateInput, mouseX, mouseY, itemInput):
	rpc_unreliable_id(gamestate.serverNetworkId, "sendPlayerInputs", movementInput, jumpId, attackStateInput, mouseX, mouseY, itemInput)

remote func setPlayerPosition(playerId, playerPosition:Vector3):
	if get_tree().get_rpc_sender_id()==gamestate.serverNetworkId:
		gamestate.setPlayerPosition(playerId, playerPosition)

remote func hurtPlayer(playerId, hpNow):
	if get_tree().get_rpc_sender_id()==gamestate.serverNetworkId:
		gamestate.hurtPlayer(playerId, hpNow)

remote func turnPlayer(playerId, direction):
	if get_tree().get_rpc_sender_id()==gamestate.serverNetworkId:
		gamestate.turnPlayer(playerId, direction)

remote func rotatePlayerOnHit(playerId, angle):
	if get_tree().get_rpc_sender_id()==gamestate.serverNetworkId:
		gamestate.rotatePlayerOnHit(playerId, angle)

remote func animatePlayer(playerId, animationType):
	if get_tree().get_rpc_sender_id()==gamestate.serverNetworkId:
		gamestate.animatePlayer(playerId, animationType)

remote func updateKills(playerId, kills):
	if get_tree().get_rpc_sender_id()==gamestate.serverNetworkId:
		gamestate.updateKills(playerId, kills)

remote func killPlayer(playerId, killerId):
	if get_tree().get_rpc_sender_id()==gamestate.serverNetworkId:
		gamestate.killPlayer(playerId, killerId)

remote func kickedFromServer(message:String):
	if get_tree().get_rpc_sender_id()==gamestate.serverNetworkId:
		gamestate.kickedFromServer(message)

remote func startZoning(centerX, centerY):
	if get_tree().get_rpc_sender_id()==gamestate.serverNetworkId:
		gamestate.startZoning(centerX, centerY)

remote func startFalling(island):
	if get_tree().get_rpc_sender_id()==gamestate.serverNetworkId:
		gamestate.startFalling(island)

remote func setNewItem(itemId, itemType, position):
	if get_tree().get_rpc_sender_id()==gamestate.serverNetworkId:
		gamestate.registerItem(itemId, itemType, position)

remote func deleteItem(itemId):
	if get_tree().get_rpc_sender_id()==gamestate.serverNetworkId:
		gamestate.deleteItem(itemId)

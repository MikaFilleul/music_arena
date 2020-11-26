extends Node

const GAMEPATH:String = "/root/game/"
var players:Dictionary = {}
var maxPlayers:int

enum {NOT_PLAYING=0, PLAYING=1, WAS_PLAYING=2}
var isPlaying:int = NOT_PLAYING

var serverNetworkId:int = 0
var isInServer:bool = false

var endGameStats:Dictionary = {
	"kills": 0,
	"rank": 0
}

signal gameFullyLoaded


#################################################################
### GODOT SIGNALS


# Network: connection failed
func connectionFailure():
	print("The client could not connect the host")


# Network: the server is not seen anymore:
func serverFailure():
	print("Server lost: The system has failed !!!")
	get_tree().quit()


#################################################################

#################################################################
### CLIENT-MAESTRO FUNCTIONS


# Log to the maetro
func loginRequest(login, password):
	# print("loginRequest(",login, " - ", password,")")
	network.loginRequest(login, password)


# --- Called by network ---
# Answer of the maestro for a authentication attempt
func loginAnswer(answer:bool, error:String):
	if answer:
		print("Login success")
		interfaces.loadNewScene(interfaces.MAIN_MENU_PATH)

	else:
		print("Login failure")
		get_node("/root/Control").loginFailureDisplay(error)


# Ask for a game server
func joinGameRequest(maxPlayers:int, pseudo:String, skinId:int):
	self.maxPlayers = maxPlayers
	self.endGameStats["rank"] = maxPlayers
	network.joinGameRequest(maxPlayers, pseudo, skinId)


# --- Called by network ---
# Answer of the maestro for a game server to join
func joinGameAnswer(serverNetworkId:int, answer:bool, error:String):
	if !answer:
		print(error)
		return
	self.serverNetworkId = serverNetworkId
	print("Game found")
	joinServerRequest()


# TODO: Ask to join a player/party from an ID
func joinPartyRequest():
	pass

func joinPartyAnswer():
	pass


func leaveServer():
	interfaces.loadNewScene(interfaces.ENDGAME_PATH)
	serverNetworkId = 0
	network.leaveServer()


#################################################################

#################################################################
### CLIENT-GAME SERVER FUNCTIONS


# Join a game-server (ID previously gave by the maestro)
func joinServerRequest():
	if !self.serverNetworkId:
		print("No server specified")
		return
	network.joinServerRequest(self.serverNetworkId)
	interfaces.loadNewScene(interfaces.LOBBY_PATH)


# --- Called by network ---
# Answer of the game server (recognized or not)
func joinServerAnswer(answer:bool, error:String):
	if !answer:
		print("Server n°", self.serverNetworkIdId, " replied with an error: ", error)
		self.serverNetworkId = 0
		interfaces.loadNewScene(interfaces.MAIN_MENU_PATH)
		return
	self.isInServer = true
	print("Game joined")


# --- Called by network ---
# Lobby communication function
func serverAlert(text:String):
	get_node("/root/lobby").serverAlert(text)


# --- Called by network ---
# Start the game
func loadGame(players:Dictionary):
	registerPlayer(players)
	interfaces.loadNewScene(interfaces.GAME_PATH)


func startGame():
	emit_signal("gameFullyLoaded")


func clientGameLoaded():
	network.clientGameLoaded(self.serverNetworkId)


# --- Called by network ---
# Register the players of the same game
func registerPlayer(players:Dictionary):
	self.players = players
	for networkId in players:
		print("Player added to the game: ", networkId)


# --- Called by network ---
# Eliminate a player from the game
func killPlayer(networkId, killerId):
	get_node("/root/game/"+str(networkId)).die(killerId)


# --- Called by network ---
# Kick the client from the game server (with a message)
# NB: Currently used to display win/lose, but is just a console print
func kickedFromServer(message:String):
	print(message)
	isPlaying = WAS_PLAYING
	leaveServer()


#################################################################

#################################################################
### OLD-SCHOOL NETWORK GAME FUNCTION => TO CHANGE ACCORDING TO THE NETWORK TEAM WORK


func setPlayerPosition(playerId, playerPosition):
	if get_node("/root").has_node("game"):
		get_node("/root/game/"+str(playerId)).set_translation(playerPosition)

func hurtPlayer(networkId, hpNow):
	get_node("/root/game/"+str(networkId)).hurt(hpNow)

func turnPlayer(networkId, direction):
	get_node("/root/game/"+str(networkId)).turn(direction)

func rotatePlayerOnHit(networkId, angle):
	get_node("/root/game/"+str(networkId)).rotatePlayerOnHit(angle)

func animatePlayer(networkId, animationType):
	if get_node("/root").has_node("game"):
		get_node("/root/game/"+str(networkId)).getAnimationTypePlay(animationType)

func startZoning(centerX, centerY):
	get_node("/root/game/").startZoning(centerX, centerY)

func startFalling(island):
	get_node("/root/game/Map/"+str(island)).startFalling()

func registerItem(itemId: int,itemType: int, position:Vector3):
	get_node("/root/game").addItem(itemId,itemType,position)

func deleteItem(itemId: int):
	if get_node("/root/game/itemCollection").has_node("item"+str(itemId)):
		get_node("/root/game/itemCollection/item"+str(itemId)).deleteItemClient()

func updateKills(networkId, kills):
	get_node("/root/game/"+str(networkId)).giveKill(kills)

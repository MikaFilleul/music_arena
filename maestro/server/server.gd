 extends Node

var maxPlayers:int	# Number of players manageable by the maestro

var awaitedClients:Array = []		# Clients awaited by the server
var registeredClients:Array = []	# Clients registered and who contacted the server

var players:Array = []	# Clients currently in the game hosted
var startTime:int		# Unix-style timestamp at the beginning of the game
# -> supposed to be empty/null until the game has started


enum {DOWN=0, UP=1, RUNNING=2}
var state:int = DOWN

var networkId:int	# Rpc id of the server
var pw:int			# Random 32b int to ensure the identity of the proc

signal initialized			# First handshake done
signal waitingForClient		# Client currently awaited handshake done

func get_class():
	return "Server"


# Constructor
func _init(maxPlayers:int):
	print("Server ", self.get_instance_id(), " created, waiting for a sign of life")
	
	self.pw = randi()
	self.maxPlayers = maxPlayers
	
	# Fork an instance of the server project with:
	# - server id
	# - server password
	# - maestro ip
	# - maestro port
	var forkArgs:PoolStringArray = [maestro.BINARIES+maestro.SERVER_BIN, str(self.get_instance_id()), str(pw), maestro.IP, str(maestro.PORT)]

	OS.execute(maestro.BINARIES+maestro.FORK_SCRIPT, forkArgs, false)


# Check if the password sent by the peer match with the one from the remote instance
func authenticate(pw:int):
	return pw==self.pw


# The server may now be used to host clients
func turnUp():
	self.state = UP
	emit_signal("initialized")


# Check if the server can host a connection request
func canHost(maxPlayers:int, partySize:int):
	return self.state==UP && self.maxPlayers==maxPlayers && awaitedClients.size()+registeredClients.size()+partySize<=self.maxPlayers


# The server was informed of an incoming client connection
func clientAwaited(clientId:int):
	awaitedClients.append(clientId)
	emit_signal("waitingForClient")


func clientJoined(clientId:int):
	awaitedClients.erase(clientId)
	registeredClients.append(clientId)


func clientLeft(clientId:int):
	registeredClients.erase(clientId)


func gameStarted():
	self.state = RUNNING
	startTime = OS.get_system_time_secs()
	players = registeredClients.duplicate()


func close(winnerId:int):
	var duration:int = OS.get_system_time_secs() - startTime
	
	var gameId:int = database.newGameRegistered(players.size(), duration)
	if gameId==-1:
		print("M:DB Warning, newGameRegistered call error, db might be desynchronized")
	
#	#gameId:int, rank:int, victory:bool, totalKills:int, liveTime:int
#	var player:Node = maestro.getClientNode(winnerId)
#	if !database.clientNewGameRegistered(player.userId, heroId, gameId, rank):
#		print("M: Warning, db call error, db might be desynchronized")
#
#	players.erase(winnerId)
#
#	for player in players:
#		pass
	
	awaitedClients.clear()
	registeredClients.clear()
	
	players.clear()

#     _    _
#    / \  /.\
#    \  \/  _\
#     \    /
#     /\  /
#      /\/




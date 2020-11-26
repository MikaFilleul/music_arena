extends Node

var peer:NetworkedMultiplayerENet

func _ready():
	
	# RPC SIGNALS
	get_tree().connect("network_peer_connected", maestro, "peerConnected")
	get_tree().connect("network_peer_disconnected", maestro, "peerDisconnected")
	
	# RPC INITIALIZATION
	peer = NetworkedMultiplayerENet.new()
	peer.set_bind_ip(maestro.IP)
	peer.create_server(maestro.PORT, maestro.MAX_CLIENTS)
	get_tree().set_network_peer(peer)
	
	# NETWORK INFOS DISPLAY
	print(" - IP:", maestro.IP, "\n - port:", maestro.PORT)


#################################################################

#################################################################
### MAESTRO-CLIENT FUNCTIONS


# Sent and received on login of a client
master func loginRequest(login:String, pw:String):
	var networkId = get_tree().get_rpc_sender_id()
	maestro.loginRequest(networkId, login, pw, peer.get_peer_address(networkId), peer.get_peer_port(networkId))

func loginAnswer(networkId:int, answer:bool, error:String=""):
	rpc_id(networkId, "loginAnswer", answer, error)


# Sent and received when a client try to join a game
master func joinGameRequest(maxPlayers:int, pseudo:String, skinId:int):
	var networkId:int = get_tree().get_rpc_sender_id()
	maestro.joinGameRequest(networkId, maxPlayers, pseudo, skinId)
	
func joinGameAnswer(clientNetworkId:int, serverNetworkId:int, answer:bool, error:String=""):
	rpc_id(clientNetworkId, "joinGameAnswer", serverNetworkId, answer, error)


# Received when a client leave a game server
master func leaveServer():
	maestro.leaveServer(get_tree().get_rpc_sender_id())

func clientLost(serverNetworkId:int, clientNetworkId:int):
	rpc_id(serverNetworkId, "clientLost", clientNetworkId)

## TODO
## Create a party which can be joined with its id
#master func createPartyRequest():
#	pass
#
#func createPartyAnswer(answer:bool, error:String):
#	rpc_id(networkId, "createPartyAnswer", false, error)


## TODO
## Join the party of the specified Id
#master func joinPartyRequest(partyId:int):
#	maestro.joinPartyRequest(get_tree().get_rpc_sender_id(), partyId)
#
#func joinPartyAnswer(networkId:int, answer:bool, error:String=""):
#	rpc_id(networkId, "joinPartyAnswer", answer, error)


#################################################################

#################################################################
### MAESTRO-SERVER FUNCTIONS


# Received when a newly forked server contacts the maestro
master func newServerForked(id:int, pw:int):
	var networkId = get_tree().get_rpc_sender_id()
	maestro.newServerConnection(id, networkId, pw)


# Initialize the servers data
func serverInitRequest(networkId:int, maxPlayers:int):
	rpc_id(networkId, "serverInitRequest", maxPlayers)

master func serverInitialized():
	maestro.newServerInitialized(get_tree().get_rpc_sender_id())


# Ask the server to wait for a specific client
func waitClientRequest(serverNetworkId:int, clientNetworkId:int, pseudo:String, skinId:int):
	rpc_id(serverNetworkId, "waitClientRequest", clientNetworkId, pseudo, skinId)

master func waitClientAnswer(clientNetworkId:int, answer:bool, error:String):
	maestro.waitClientAnswer(get_tree().get_rpc_sender_id(), clientNetworkId, answer, error)


# Server has been joined by the specified client
master func clientJoinedServer(clientNetworkId:int):
	maestro.clientJoinedServer(get_tree().get_rpc_sender_id(), clientNetworkId)


# Alert from server: the game may start and is waiting for maestro validation (sync)
master func gameHasStarted():
	maestro.gameHasStarted(get_tree().get_rpc_sender_id())

func serverValidation(serverNetworkId:int):
	rpc_id(serverNetworkId, "serverValidation")


# Alert from server: the game has ended with the specified client as winner, reset the server for a new game
master func gameHasEnded(clientNetworkId:int):
	maestro.gameHasEnded(get_tree().get_rpc_sender_id(), clientNetworkId)


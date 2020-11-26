extends Node

const IP:String = "91.121.81.74"#"127.0.0.1"
var PORT:int = 10001


# Binary file to create a game server in a fork
const BINARIES:String 		= "./"
const FORK_SCRIPT:String	= "forker.arena"
const SERVER_BIN:String		= "server.pck"


# Maximum capacities
const MAX_CLIENTS:int = 64
var clientsConnected:int = 0

const MAX_SERVERS:int = 10
var serversCreated:int = 0
var serversIdOnline:Array = []

# Parties and players management classes
onready var Client:GDScript = preload("../client/client.gd")
onready var Server:GDScript = preload("../server/server.gd")

var network2Id:Dictionary = {}

func _ready():
	print("Maestro here !")
	
	# If a port is specified, use it
	if OS.get_cmdline_args().size() == 1:
		PORT = int(OS.get_cmdline_args()[0].split('=')[1])


##################################################################
### UTILITY


# --- Called by network (signal) ---
func peerConnected(networkId):
	pass


# --- Called by network (signal) ---
# If the peer was known, properly erase him from the game (maestro and possibly server)
func peerDisconnected(networkId):
	if network2Id.has(networkId):
		match instance_from_id(network2Id[networkId]).get_class():
			"Client":
				clientLost(networkId)
			"Server":
				serverLost(networkId)


#################################################################

#################################################################
### CLIENT FUNCTIONS


# Return the node matching with the client Id
func getClientNode(clientId:int):
	var node:Node = get_node("/root/"+str(clientId))
	if node.get_class()=="Client":
		return node
	else:
		print("M: The node ", clientId, " is not a client")
		return null


# --- Called by network ---
# Connection of a new client to the maestro
func loginRequest(networkId, login:String, pw:String, address:String, port:int):
	# Client already connected
	if network2Id.keys().has(networkId):
		network.loginAnswer(networkId, false, "Player already connected")
		print("M: Client already connect (rpc:",networkId,")")
		return

	# => Client recognized
	var clientNode:Node = authenticateClient(networkId, address, port, login, pw)
	if is_instance_valid(clientNode):
		if (!database.connectionUpdate(clientNode.userId)):
			print("M:DB Warning, connectionUpdate call error, db might be desynchronized")
		network.loginAnswer(networkId, true)
		print("M: Client rpc:",networkId," connected, id is ", network2Id[networkId])
	
	# => Client not recognized
	else:
		network.loginAnswer(networkId, false, "Login failure")
		print("M: login failure (rpc:", networkId, ")")


# Authenticate with DB call and create a new player if recognized
func authenticateClient(networkId:int, address, port, login, pw):
	var userId:int = database.userExists(login, pw)
	
	if userId==-1:
		print("M: Authentification error")
		return null
	
	var newClient:Object = Client.new(networkId, address, port, userId, login, pw)
	network2Id[networkId] = newClient.get_instance_id()
	newClient.set_name(str(newClient.get_instance_id()))
	get_tree().get_root().add_child(newClient)
	return newClient


# --- Called by network ---
# A client wants to join a game
func joinGameRequest(clientNetworkId:int, maxPlayersDesired:int, pseudo:String, skinId:int):
	var client:Node = getClientNode(network2Id[clientNetworkId])
	if client.currentServerId!=-1:
		print("M: Error, player already in a game")
		return

	var chosenOne:Node = null

	# Check for a matching server in the nodes
	for serverId in serversIdOnline:
		var server:Node = getServerNode(serverId)
		if server.canHost(maxPlayersDesired, 1):
			chosenOne = server
			client.currentServerId = chosenOne.get_instance_id()
			break

	# No matching server found => Create a new one
	if !is_instance_valid(chosenOne):
		print("M: No valid server found, creation of a new one")
		chosenOne = newServer(maxPlayersDesired)
		client.currentServerId = chosenOne.get_instance_id()
		
		yield(chosenOne, "initialized")
	
	network.waitClientRequest(chosenOne.networkId, clientNetworkId, pseudo, skinId)
	yield(chosenOne, "waitingForClient")
	network.joinGameAnswer(clientNetworkId, chosenOne.networkId, true)


# Ask for the creation of a party: NO NEW SERVER (host the other clients IDs in the host object
func createPartyRequest(networkId, maxPlayersInParty:int):
	pass
#	if partiesCreated>=MAX_PARTIES:
#		network.createPartyAnswer(networkId, false, "The server can't handle anymore party ...")
#
#	else:
#		newParty(network2Id[networkId], maxPlayersInParty)
#		network.createPartyAnswer(networkId, true)


# Ask to join a specific party (use its ID)
func joinPartyRequest(networkId:int, partyId:int):
	pass
#	if !get_node("/root").has_node(str(partyId)):
#		network.joinPartyAnswer(networkId, false, "The party doesn't exist")
#		return
#
#	else:
#		joinParty(network2Id[networkId], partyId)
#		network.joinPartyAnswer(networkId, true, "Party "+str(partyId)+" successfuly joined")


func leaveServer(networkId):
	var client:Node = getClientNode(network2Id[networkId])
	if is_instance_valid(client):
		if client.currentServerId!=-1:
			print("M: Client ", network2Id[networkId], " was purged from server ", client.currentServerId)
			
			var server:Node = getServerNode(client.currentServerId)
			server.clientLeft(network2Id[networkId])
			network.clientLost(server.networkId, networkId)
			client.currentServerId = -1
	else:
		print("M: Error, client ", network2Id[networkId], " node not found !!!")


func clientLost(clientNetworkId:int):
	var client:Node = getClientNode(network2Id[clientNetworkId])
	print("M: Client ", client.get_instance_id()," rpc:", client.networkId, " left the maestro")
	
	if (!database.disconnectionUpdate(client.userId)):
		print("M:DB Warning, disconnectionUpdate call error, db might be desynchronized")
	
	leaveServer(clientNetworkId)
	client.queue_free()
	network2Id.erase(clientNetworkId)


#################################################################

#################################################################
### SERVER FUNCTIONS


# Return the node matching with the server Id or null
func getServerNode(serverId:int):
	var node:Node = get_node("/root/"+str(serverId))
	if node.get_class()=="Server":
		return node
	else:
		print("M: The node ", serverId, " is not a server")
		return null


# Create a new server node, add it to the tree and return it
# => lead to the execution of the forking script and thus a new server project
func newServer(maxPlayers:int):
	if serversCreated>=MAX_SERVERS:
		print("M: Can't handle anymore server !!!")
		return null
	serversCreated+=1
	var newServer:Object = Server.new(maxPlayers)
	newServer.set_name(str(newServer.get_instance_id()))
	get_tree().get_root().add_child(newServer)
	return newServer


# --- Called by network ---
# A new server process contacts the maestro
func newServerConnection(instanceId:int, networkId:int, pw:int):
	var server:Node = getServerNode(instanceId)
	if is_instance_valid(server) && server.authenticate(pw):
		server.networkId = networkId
		network2Id[networkId] = instanceId
		network.serverInitRequest(networkId, server.maxPlayers)
	else:
		print("M: Peer ", networkId, " joined as a server but no matching node was found")


# --- Called by network ---
# Server created by fork is now authenticated and usable
func newServerInitialized(serverNetworkId:int):
	serversIdOnline.append(network2Id[serverNetworkId])
	getServerNode(network2Id[serverNetworkId]).turnUp()


# --- Called by network ---
# The server is still up and now waiting for the specified client
func waitClientAnswer(serverNetworkId:int, clientNetworkId:int, answer:bool, error:String):
	if !answer:
		print(error)
		return
	getServerNode(network2Id[serverNetworkId]).clientAwaited(network2Id[clientNetworkId])


# --- Called by network ---
# The server is still up and was joined by the specified awaited client
func clientJoinedServer(serverNetworkId:int, clientNetworkId:int):
	var serverId:int = network2Id[serverNetworkId]
	var clientId:int = network2Id[clientNetworkId]
	
	var server:Node = getServerNode(serverId)
	var client:Node = getClientNode(clientId)
	
	if !is_instance_valid(server)||!is_instance_valid(client):
		print("M: Error, clientJoinedServer called with an unrecognized client or server id")
		return
	
	server.clientJoined(clientId)
	client.joinedServer(serverId)


# --- Called by network ---
# The game of the server can start: update the node and send validation
func gameHasStarted(serverNetworkId:int):
	var server:Node = getServerNode(network2Id[serverNetworkId])
	if is_instance_valid(server):
		server.gameStarted()
	network.serverValidation(serverNetworkId)


# --- Called by network ---
# The game of the server specified has ended: reset/destroy the server
func gameHasEnded(serverNetworkId:int, clientNetworkId:int):
	var serverId:int = network2Id[serverNetworkId]
	var clientId:int = network2Id[clientNetworkId]
	var server:Node = getServerNode(serverId)
	if is_instance_valid(server):
		print("M: Server ", serverId, " finished its game, client ", clientId, " won")
		server.close(clientId)
	else:
		print("M: Error, incoherent scene tree")


# A server peer rpc has been lost
func serverLost(networkId):
	var serverId = network2Id[networkId]
	serversIdOnline.erase(serverId)
	getServerNode(serverId).queue_free()
	network2Id.erase(networkId)

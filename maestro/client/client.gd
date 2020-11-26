extends Node

var networkId:int	# rpc id
var address:String	# IP address
var port:int		# port of client

var userId:int
var login:String	# login of client
var pw:String			# hashed password

#var currentPartyId:int = -1	# instance Id of the game of the player
var currentServerId:int = -1


# Node identification
func get_class():
	return "Client"


# Constructor: Initialize the vars
func _init(networkId:int, address:String, port:int, userId:int, login:String, pw:String):
	# Network vars
	self.networkId = networkId
	self.address = address
	self.port = port

	# DB vas
	self.userId = userId
	self.login = login
	self.pw = pw


# Compare ip, login and hashed password
func compare(address, login, pw):
	return self.address==address&&self.login==login&&self.pw==pw


# Update the registered
func joinedServer(serverId):
	self.currentServerId = serverId


func logout():
	pass

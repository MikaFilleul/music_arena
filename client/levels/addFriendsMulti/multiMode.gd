extends Node

var addFriendsButton
var idGameZone
var BACK
var OPTIONS
var CREATE
var JOIN
var PLAY

var profilePic = preload("res://levels/commons/assets/profile.png")
var binPic = preload("res://levels/commons/assets/bin.png")
var theme = preload("res://levels/commons/themes/testTheme.tres")
var panelTheme = preload("res://levels/commons/themes/panelAddFriends.tres")

func _ready():
	interfaces.LAST_WINDOWS_OPTIONS = interfaces.ADD_FRIENDS_MULTI_PATH

	BACK = $MarginContainer/VBoxContainer/header/Control/headerContainer/HBoxContainer/back
	OPTIONS = $MarginContainer/VBoxContainer/header/Control/headerContainer/HBoxContainer/options
	idGameZone = $MarginContainer/VBoxContainer/MarginContainer/Main/join/Panel2/MarginContainer/HBoxContainer/idPartyJoin
	CREATE = $MarginContainer/VBoxContainer/MarginContainer/Main/create/Panel/MarginContainer/HBoxContainer/createButton
	JOIN = $MarginContainer/VBoxContainer/MarginContainer/Main/join/Panel2/MarginContainer/HBoxContainer/joinButton
	PLAY = $MarginContainer/VBoxContainer/MarginContainer/Main/solo/playButton

	BACK.connect("pressed", self, "buttonHeader", ["back"])
	OPTIONS.connect("pressed", self, "buttonHeader", ["settings"])
	CREATE.connect("pressed", self, "buttonGame", ["create"])
	JOIN.connect("pressed", self, "buttonGame", ["join"])
	PLAY.connect("pressed", self, "buttonGame", ["play"])


func buttonHeader(button_name):

	if button_name == "back":
		interfaces.loadNewScene(interfaces.SELECT_GAME_PATH)
	elif button_name == "settings":
		interfaces.loadNewScene(interfaces.SETTINGS_PATH)

func buttonGame(button_name):
	if button_name == "play":
		# comme le play actuel
		interfaces.loadNewScene(interfaces.LOADING_SCREEN_PATH)
	elif button_name == "join":
		# recup l'id
		var gameID = idGameZone.get_text()
		# check que l'id existe
		if gameID != "":
			# lance la game comme il faut
			interfaces.gameID = gameID
			interfaces.loadNewScene(interfaces.LOADING_JOIN_PATH)
	elif button_name == "create":
		# crée un id de partie
		# faut qu'on le recup pour l'afficher sur le loading_master
		interfaces.loadNewScene(interfaces.LOADING_MASTER_PATH)

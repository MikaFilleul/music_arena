extends Control

# Rank zone size
#var ratioX = 340/1024
#var ratioY = 140/600
var xWindow
var yWindow

var PANELSTATS
var BACK
var MARGIN

var LULLABY
var ANGELA
var FRANKY
var WEED
var METAL
var ELECTRO
var DEFAULT

func _ready():
	xWindow = get_viewport().size.x
	yWindow = get_viewport().size.y
	
	# Variables
	PANELSTATS = $VBoxContainer/MarginContainer/VBoxContainer/container/endGameInfos/Panel
	BACK = $VBoxContainer/header/Control/headerContainer/HBoxContainer/back
	
	# Win background
	LULLABY = $lullabywin
	ANGELA = $angelawin
	FRANKY = $discowin
	WEED = $weedwin
	METAL = $metalwin
	ELECTRO = $robotwin
	DEFAULT = $defaultwin
	
	# Buttons connect
	BACK.connect("pressed", self, "buttonHeader", ["back"])
	
	# Resize functions
	PANELSTATS.set_custom_minimum_size(Vector2(330,140))
	MARGIN = $VBoxContainer/MarginContainer/VBoxContainer/container
	var margins = (yWindow-140)/6
	MARGIN.set("custom_constants/margin_top", margins)
	MARGIN.set("custom_constants/margin_bottom", margins)
	get_tree().get_root().connect("size_changed", self, "resize")
	
	# Display stats
	
	# On doit récupérer le personnage joué pour idCharacter
	# En théorie 1 = Lullaby, 2 = Disco, 3 = Angela, 4 = WeedMan, 5 = Metal, 6 = Electrorobot, 0 = Default (dans l'optique où on propose un default)
	var idCharacter = gamestate.players[get_tree().get_network_unique_id()]["skin"]
	# Nombre de personnage tué par le joueur courant
	var kills = gamestate.endGameStats["kills"]
	# Rank = position du joueur à sa mort
	var rank
	var message
	var music
	if gamestate.players[get_tree().get_network_unique_id()]["status"] == "dead":
		rank = gamestate.endGameStats["rank"]+1
		message = "Mission failed!"
		music = load("res://models/music/defeat.wav")
	else:
		rank = 1
		message = "We are the champions, my friend!"
		music = load("res://models/music/victory.wav")
	# nbPlayer = nombre de joueurs total dans la partie (2,4,8,16,32)
	var nbPlayers = gamestate.maxPlayers
	displayBg(idCharacter)
	displayStats(rank,nbPlayers,kills,message,music)
	
func buttonHeader(button_name):
	if button_name == "back":
		interfaces.loadNewScene(interfaces.MAIN_MENU_PATH)

# Display win background
func displayBg(charID):
	if charID == 0:
		LULLABY.visible = true
		ANGELA.visible = false
		FRANKY.visible = false
		WEED.visible = false
		METAL.visible = false
		ELECTRO.visible = false
		DEFAULT.visible = false
	elif charID == 1:
		LULLABY.visible = true
		ANGELA.visible = false
		FRANKY.visible = false
		WEED.visible = false
		METAL.visible = false
		ELECTRO.visible = false
		DEFAULT.visible = false
	elif charID == 2:
		LULLABY.visible = false
		ANGELA.visible = false
		FRANKY.visible = true
		WEED.visible = false
		METAL.visible = false
		ELECTRO.visible = false
		DEFAULT.visible = false
	elif charID == 3:
		LULLABY.visible = false
		ANGELA.visible = true
		FRANKY.visible = false
		WEED.visible = false
		METAL.visible = false
		ELECTRO.visible = false
		DEFAULT.visible = false
	elif charID == 4:
		LULLABY.visible = false
		ANGELA.visible = false
		FRANKY.visible = false
		WEED.visible = true
		METAL.visible = false
		ELECTRO.visible = false
		DEFAULT.visible = false
	elif charID == 5:
		LULLABY.visible = false
		ANGELA.visible = false
		FRANKY.visible = false
		WEED.visible = false
		METAL.visible = true
		ELECTRO.visible = false
		DEFAULT.visible = false
	elif charID == 6:
		LULLABY.visible = false
		ANGELA.visible = false
		FRANKY.visible = false
		WEED.visible = false
		METAL.visible = false
		ELECTRO.visible = true
		DEFAULT.visible = false

# Display stats
func displayStats(rank,nbPlayers,kills,message,music):
	var playerRank = $VBoxContainer/MarginContainer/VBoxContainer/container/endGameInfos/Panel/rankinContainer/rankingInfos/ranking/playerrank
	var numberPlayers = $VBoxContainer/MarginContainer/VBoxContainer/container/endGameInfos/Panel/rankinContainer/rankingInfos/ranking/numberofplayers
	var killZone = $VBoxContainer/MarginContainer/VBoxContainer/container/endGameInfos/kills/nbKills
	var messageText = $VBoxContainer/MarginContainer/VBoxContainer/container/endGameInfos/endMessage
	playerRank.set_text(str(rank))
	numberPlayers.set_text(str(nbPlayers))
	killZone.set_text(str(kills))
	messageText.set_text(message)
	var musicNode = get_node("MusicNode/Music")
	musicNode.set_stream(music)
	musicNode.play()

# Resize the stats bloc
func resize():
	xWindow = get_viewport_rect().size.x
	yWindow = get_viewport_rect().size.y
	var margins = (yWindow-116)/6
	MARGIN.set("custom_constants/margin_top", margins)
	MARGIN.set("custom_constants/margin_bottom", margins)


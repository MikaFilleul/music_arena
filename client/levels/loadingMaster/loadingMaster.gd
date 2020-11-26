extends Control

var idGameZone
var BACK
var OPTIONS
var PLAY

# Called when the node enters the scene tree for the first time.
func _ready():
	interfaces.LAST_WINDOWS_OPTIONS = interfaces.LOADING_MASTER_PATH
	
	#BACK = $MarginContainer/VBoxContainer/header/Control/headerContainer/HBoxContainer/back
	#OPTIONS = $MarginContainer/VBoxContainer/header/Control/headerContainer/HBoxContainer/options
	idGameZone = $MarginContainer/VBoxContainer/MarginContainer/Main/create/Panel/infosContainer/HBoxContainer/labelID
	PLAY = $MarginContainer/VBoxContainer/MarginContainer/Main/solo/letsPlay
	
	#BACK.connect("pressed", self, "buttonHeader", ["back"])
	#OPTIONS.connect("pressed", self, "buttonHeader", ["settings"])
	PLAY.connect("pressed", self, "buttonGame", ["play"])
	
	setID()
	
# On peut pas partir une fois qu'on est là j'pense
#func buttonHeader(button_name):
#	if button_name == "back":
#		interfaces.loadNewScene(interfaces.ADD_FRIENDS_MULTI_PATH)
#	elif button_name == "settings":
#		interfaces.loadNewScene(interfaces.SETTINGS_PATH)
	
	
# Ce serait censé lancer la game
# La recherche si y a pas assez de monde
# Ou direct lancer le jeu si ils sont assez
func buttonGame(button_name):
	if button_name == "play":
		# je sais pas comment ça se passe 
		pass

# Ce serait censé afficher l'ID de la game à la place de brrrrrr
func setID():
	#var globals = get_node("/root/Globals")
	idGameZone.set_text("#"+str("brrrrrr"))


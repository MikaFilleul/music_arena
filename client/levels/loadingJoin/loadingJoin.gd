extends Control

var idGameZone
var BACK
var OPTIONS
var PLAY

# Called when the node enters the scene tree for the first time.
func _ready():
	interfaces.LAST_WINDOWS_OPTIONS = interfaces.LOADING_JOIN_PATH
	
	#BACK = $MarginContainer/VBoxContainer/header/Control/headerContainer/HBoxContainer/back
	#OPTIONS = $MarginContainer/VBoxContainer/header/Control/headerContainer/HBoxContainer/options
	idGameZone = $MarginContainer/VBoxContainer/MarginContainer/Main/create/Panel/infosContainer/HBoxContainer/labelID
	
	#BACK.connect("pressed", self, "buttonHeader", ["back"])
	#OPTIONS.connect("pressed", self, "buttonHeader", ["settings"])
	
	setID()
	# faire en sorte que la game se lance quand elle est prête
	
# Théoriquement on peut pas se barrer dès qu'on est en train d'attendre
#func buttonHeader(button_name):
#	if button_name == "back":
#		interfaces.loadNewScene(interfaces.ADD_FRIENDS_MULTI_PATH)
#	elif button_name == "settings":
#		interfaces.loadNewScene(interfaces.SETTINGS_PATH)

# Ce serait censé afficher l'ID de la game à la place de brrrrrr
func setID():
	# Recupérer l'id qu'on a rentré avant (supposément gardé dans interfaces.gd)
	idGameZone.set_text("#"+str(interfaces.gameID))

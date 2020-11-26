extends Control

# Play mode
var MODE2
var MODE4
var MODE8
var MODE16
var MODE32
var BACK
var OPTIONS

func _ready():
	# Get the globals singleton and set the back button options
	interfaces.LAST_WINDOWS_OPTIONS = interfaces.SELECT_GAME_PATH

	# Get the buttons
	MODE2 = $MarginContainer/VBoxContainer/multiContainer/multiSelectV/top/firstLignSelection/Players2Zone/Players2
	MODE4 = $MarginContainer/VBoxContainer/multiContainer/multiSelectV/top/firstLignSelection/Players4Zone/Players4
	MODE8 = $MarginContainer/VBoxContainer/multiContainer/multiSelectV/top/firstLignSelection/Players8Zone/Players8
	MODE16 =$MarginContainer/VBoxContainer/multiContainer/multiSelectV/bottom/secondLignSelection/Players16Zone/Players16
	MODE32 =$MarginContainer/VBoxContainer/multiContainer/multiSelectV/bottom/secondLignSelection/Players33Zone/Players33
	BACK = $MarginContainer/VBoxContainer/header/Control/headerContainer/HBoxContainer/back
	OPTIONS = $MarginContainer/VBoxContainer/header/Control/headerContainer/HBoxContainer/options

	# Connect the buttons with their destinations
	MODE2.connect("pressed", self, "selectedGame", ["play",2])
	MODE4.connect("pressed", self, "selectedGame", ["play",4])
	MODE8.connect("pressed", self, "selectedGame", ["play",8])
	MODE16.connect("pressed", self, "selectedGame", ["play",16])
	MODE32.connect("pressed", self, "selectedGame", ["play",32])
	BACK.connect("pressed", self, "buttonHeader", ["back"])
	OPTIONS.connect("pressed", self, "buttonHeader", ["settings"])


func selectedGame(button_name,playerNumber):
	if button_name == "play":
		interfaces.NUMBER_OF_PLAYERS = playerNumber
		interfaces.loadNewScene(interfaces.SELECT_CHAR_PATH)

func buttonHeader(button_name):
	if button_name == "back":
		interfaces.loadNewScene(interfaces.MAIN_MENU_PATH)
	elif button_name == "settings":
		interfaces.loadNewScene(interfaces.SETTINGS_PATH)

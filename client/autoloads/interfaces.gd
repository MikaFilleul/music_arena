extends Node


# Path of the interfaces
const MAIN_MENU_PATH:String = "res://levels/mainMenu/MainMenu.tscn"
const ADD_FRIENDS_MULTI_PATH:String = "res://levels/addFriendsMulti/MultiMode.tscn"
const CREDITS_PATH:String = "res://levels/credits/Credits.tscn"
const END_GAME_PATH:String = "res://levels/endGame/EndGame.tscn"
const LOADING_SCREEN_PATH:String = "res://levels/loadingScreen/LoadingScreen.tscn"
const LOADING_JOIN_PATH:String = "res://levels/loadingJoin/LoadingJoin.tscn"
const LOADING_MASTER_PATH:String = "res://levels/loadingMaster/LoadingMaster.tscn"
const LOBBY_PATH:String = "res://levels/lobby/lobby.tscn"
const LOGIN_PATH:String = "res://levels/login/Login.tscn"
const PROFILE_PATH:String = "res://levels/profile/Profile.tscn"
const SELECT_CHAR_PATH:String = "res://levels/selectChar/CharacterSelection.tscn"
const SELECT_GAME_PATH:String = "res://levels/selectGame/MultiSelectMenu.tscn"
const SETTINGS_PATH:String = "res://levels/settings/Settings.tscn"
const GAME_PATH:String = "res://levels/test/game.tscn"
const ENDGAME_PATH:String = "res://levels/endGame/EndGame.tscn"


# Path to the last opened windows (for option's back)
var LAST_WINDOWS_OPTIONS = "res://levels/mainMenu/MainMenu.tscn"

# ------------------------------------
# Game values
var NUMBER_OF_PLAYERS = 0
var CHARACTER_SELECTED = "Default"
var pseudo = "anonymous"
# List of username
#var FRIENDS = []
# Number of friends
#var NUMBER_OF_FRIENDS = 0
# ID of the game
var gameID = 458785

# ------------------------------------
# All of the GUI/UI related variables

# The popup scene, and a variable to hold the popup
#const POPUP_SCENE = preload("res://Pause_Popup.tscn")
var popup = null

# A canvas layer node so our GUI/UI is always drawn on top
var canvas_layer = null

# The debug display scene, and a variable to hold the debug display
#const DEBUG_DISPLAY_SCENE = preload("res://Debug_Display.tscn")
var debug_display = null

# ------------------------------------


# A variable to hold all of the respawn points in a level
#var respawn_points = null

# A variable to hold the mouse sensitivity (so Player.gd can load it)
#var mouse_sensitivity = 0.08
# A variable to hold the joypad sensitivity (so Player.gd can load it)
#var joypad_sensitivity = 2


# ------------------------------------
# All of the audio files.

# You will need to provide your own sound files.
# One site I'd recommend is GameSounds.xyz. I'm using Sonniss' GDC Game Audio bundle for 2017.
# The tracks I've used (with some minor editing) are as follows:
#	Gamemaster audio gun sound pack:
#		gun_revolver_pistol_shot_04,
#		gun_semi_auto_rifle_cock_02,
#		gun_submachine_auto_shot_00_automatic_preview_01

# The simple audio player scene
#const SIMPLE_AUDIO_PLAYER_SCENE = preload("res://Simple_Audio_Player.tscn")

# A list to hold all of the created audio nodes
#var created_audio = []

# ------------------------------------


func _ready():
	# Randomize the random number generator, so we get random values
	randomize()

	# Make a new canvas layer.
	# This is so our popup always appears on top of everything else
	canvas_layer = CanvasLayer.new()
	add_child(canvas_layer)

	#set screen size to the viewport size
	OS.set_window_maximized(true)


func loadNewScene(new_scene_path):
	# Change scenes
	var error = get_tree().change_scene(new_scene_path)
	if (error != OK):
		print("Error: %s" % error)


# func _process(_delta):
# 	# If ui_cancel is pressed, we want to open a popup if one is not already open
# 	if Input.is_action_just_pressed("ui_cancel"):
# 		if popup == null:
# 			# Make a new popup scene

# 			# Connect the signals
# 			popup.get_node("Button_quit").connect("pressed", self, "popup_quit")
# 			popup.connect("popup_hide", self, "popup_closed")
# 			popup.get_node("Button_resume").connect("pressed", self, "popup_closed")

# 			# Add it as a child, and make it pop up in the center of the screen
# 			canvas_layer.add_child(popup)
# 			popup.popup_centered()

# 			# Make sure the mouse is visible
# 			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

# 			# Pause the game
# 			get_tree().paused = true


# func popup_closed():
# 	# Unpause the game
# 	get_tree().paused = false

# 	# If we have a popup, destoy it
# 	if popup != null:
# 		popup.queue_free()
# 		popup = null


# func popup_quit():
# 	get_tree().paused = false

# 	# Make sure the mouse is visible
# 	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

# 	# If we have a popup, destoy it
# 	if popup != null:
# 		popup.queue_free()
# 		popup = null

# 	# Go back to the title screen scene
# 	loadNewScene(MAIN_MENU_PATH)

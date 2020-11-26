extends Control

var LISTPLAYER
var PLAYERDISPLAY

var SETTINGSDISPLAY

var MOBILEPLAYERSBUTTON
var MOBILESETTINGSBUTON

var profilePic = preload("res://models/listPlayer/profile.png")
var t = preload("res://models/listPlayer/testTheme.tres")
var panelTheme = preload("res://levels/commons/themes/panelAddFriends.tres")

var userDamages
var userName
var userImg
var nbKills
var inventory

func _ready():
	LISTPLAYER = $listPlayers/Panel/MarginContainer/VBoxContainer/playerContainer/marginPlayer/playersList
	PLAYERDISPLAY = $listPlayers
	SETTINGSDISPLAY = $settings
	# MOBILEPLAYERSBUTTON = $playerlistZone
	# MOBILESETTINGSBUTON = $settingsZone
	userDamages = $MarginContainer/VBoxContainer/bas/stats/percent
	userName = $MarginContainer/VBoxContainer/bas/stats/VBoxContainer/name
	userImg = $MarginContainer/VBoxContainer/bas/stats/VBoxContainer/pic
	nbKills = $MarginContainer/VBoxContainer/bas/lastHit/VBoxContainer/kills
	inventory = $MarginContainer/VBoxContainer/bas/stats/inventaire/obj
	displayListPlayer()
	displayNbKills(0)
	showInventory("res://models/player/playerArrow/playerArrow.png")

func _input(ev):
	if ev is InputEventKey :
		if ev.is_echo() and ev.scancode == KEY_TAB and SETTINGSDISPLAY.visible == false:
			#(print(OS.get_scancode_string(ev.scancode)))
			PLAYERDISPLAY.visible = true
		if !ev.is_echo() and ev.scancode == KEY_TAB:
			PLAYERDISPLAY.visible = false

		elif ev.pressed and ev.scancode == KEY_ESCAPE and PLAYERDISPLAY.visible == false:
			if SETTINGSDISPLAY.visible == false:
				# print("true")
				SETTINGSDISPLAY.visible = true
			elif SETTINGSDISPLAY.visible == true:
				# print("false")
				SETTINGSDISPLAY.visible = false
		#else:
		#	PLAYERDISPLAY.visible = false

# display the player list
func displayListPlayer():
	# on recup les players de la game en cours dans cette fonction
	# pour le moment idk comment on les recup
	for id in gamestate.players:
		addPlayer(str(id), "Funky Francky")

func addPlayer(playerName,characterPlayed):
	var pseudo = ""+playerName+" - "+characterPlayed+""
	# Create the objects to add
	var newPlayer = HBoxContainer.new()
	var newPanel = Panel.new()
	var newPseudo = Label.new()
	var newTextureProfile = TextureButton.new()
	var margins = MarginContainer.new()
	# Set their values
	#HBoxContainer& margins
	newPlayer.set("custom_constants/separation", 15)
	margins.set_anchors_preset(15)
	var margin_value = 2.5
	margins.set("custom_constants/margin_top", margin_value)
	margins.set("custom_constants/margin_left", margin_value+5)
	margins.set("custom_constants/margin_bottom", margin_value)
	margins.set("custom_constants/margin_right", margin_value+5)
	##Panel
	newPanel.set_theme(panelTheme)
	newPanel.set_h_size_flags(1)
	newPanel.set_v_size_flags(1)
	newPanel.set_custom_minimum_size(Vector2(newPanel.get_size().x,30))
	## Pseudo
	newPanel.set_name(playerName)
	newPseudo.set_text(pseudo)
	newPseudo.set_h_size_flags(3)
	newPseudo.set_v_size_flags(4)
	#newPseudo.set_theme(t)
	## Profile icon
	newTextureProfile.set_normal_texture(profilePic)
	newTextureProfile.set_expand(true)
	newTextureProfile.set_custom_minimum_size(Vector2(25,25))
	newTextureProfile.set_stretch_mode(4)
	newTextureProfile.set_h_size_flags(1)
	newTextureProfile.set_v_size_flags(7)
	# Add them
	newPanel.add_child(margins)
	margins.add_child(newPlayer)
	newPlayer.add_child(newTextureProfile)
	newPlayer.add_child(newPseudo)
	LISTPLAYER.add_child(newPanel)

func displayDamages(value):
	userDamages.text = str(value) + " %"

func displayUser(name,img):
	userName.text = name
	userImg.texture = load(img)

func displayNbKills(value):
	nbKills.text = str(value)

func showInventory(img):
	inventory.texture = load(img)

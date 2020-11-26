extends Control

var LISTPLAYER
var PLAYERDISPLAY

var PRESSED = 1

var profilePic = preload("res://models/listPlayer/profile.png")
#var themePseudo = preload("res://levels/commons/themes/labelSkillFont.tres")
var panelTheme = preload("res://levels/commons/themes/panelAddFriends.tres")

# pour le moment c'est moche, dsl
# c'est à cause des thèmes

func _ready():
	LISTPLAYER = $listPlayers/Panel/MarginContainer/VBoxContainer/playerContainer/marginPlayer/playersList
	PLAYERDISPLAY = $listPlayers
	# listPlayer is a list like [[player1,char],[player2,char],...]
	var listPlayer = []
	# Total of players in the game
	var nbPlayers = 16
	displayListPlayer([],16)
	#set_process_input(true) 
	

func _input(ev):
	if ev is InputEventKey:
		#if not(ev.is_echo()) and ev.get_scancode() == 16777218:
			#(print(OS.get_scancode_string(ev.scancode)))
			#print("bruh")
			#PLAYERDISPLAY.visible = true
		if ev.is_echo() and ev.get_scancode() == 16777218:
			#(print(OS.get_scancode_string(ev.scancode)))
			PLAYERDISPLAY.visible = true
		else:
			PLAYERDISPLAY.visible = false

# Display the player list
func displayListPlayer(listPlayer,nbPlayers):
	for i in range(0,nbPlayers-1):
		addPlayer("salu","Paco le roi du disco")
		# We'll used this instead
		# addPlayer(listPlayer[i][0],listPlayer[i][1])
	
# Add the player and the character played in the player list
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
	#newPseudo.set_theme(themePseudo)
	newPseudo.set_text(pseudo)
	newPseudo.set_h_size_flags(3)
	newPseudo.set_v_size_flags(4)
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

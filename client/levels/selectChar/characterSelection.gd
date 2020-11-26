extends Control

var xWindow = 0
var yWindow = 0
var ratio = float(300)/float(430)

var SKILL_1
var SKILL_2
var SKILL_3
var SKILL_4

var CHAR1
var CHAR2
var CHAR3
var CHAR4
var CHAR5
var CHAR6
var BACK
var OPTIONS
var PLAY

var CHARPIC1 = preload("res://levels/selectChar/assets/charPic.jpg")
var CHARPIC2 = preload("res://levels/selectChar/assets/charPic.jpg")
var CHARPIC3 = preload("res://levels/selectChar/assets/charPic.jpg")
var CHARPIC4 = preload("res://levels/selectChar/assets/charPic.jpg")

var currentChar = 2
enum {
	SKIN_DEFAULT = 0,
	SKIN_LULLABY = 1,
	SKIN_DISCO = 2,
	SKIN_ANGELA = 3,
	SKIN_REGGAE = 4,
	SKIN_METAL = 5,
	SKIN_ELECTRO = 6
}

func _ready():
	interfaces.LAST_WINDOWS_OPTIONS = interfaces.SELECT_CHAR_PATH

	###skills
	SKILL_1 = $MarginContainer/VBoxContainer/marginSelectContainer/container/character/marginCharRight/verticalAlignment/marginSkills/skills/skillBar1
	SKILL_2 = $MarginContainer/VBoxContainer/marginSelectContainer/container/character/marginCharRight/verticalAlignment/marginSkills/skills/skillBar2
	SKILL_3 = $MarginContainer/VBoxContainer/marginSelectContainer/container/character/marginCharRight/verticalAlignment/marginSkills/skills/skillBar3
	SKILL_4 = $MarginContainer/VBoxContainer/marginSelectContainer/container/character/marginCharRight/verticalAlignment/marginSkills/skills/skillBar4

	###charactersButtons
	CHAR1 = $MarginContainer/VBoxContainer/marginSelectContainer/container/selection/charListContainer/ScrollContainer/GridContainer/char1
	CHAR2 = $MarginContainer/VBoxContainer/marginSelectContainer/container/selection/charListContainer/ScrollContainer/GridContainer/char2
	CHAR3 = $MarginContainer/VBoxContainer/marginSelectContainer/container/selection/charListContainer/ScrollContainer/GridContainer/char3
	CHAR4 = $MarginContainer/VBoxContainer/marginSelectContainer/container/selection/charListContainer/ScrollContainer/GridContainer/char4
	CHAR5 = $MarginContainer/VBoxContainer/marginSelectContainer/container/selection/charListContainer/ScrollContainer/GridContainer/char5
	CHAR6 = $MarginContainer/VBoxContainer/marginSelectContainer/container/selection/charListContainer/ScrollContainer/GridContainer/char6

	BACK = $MarginContainer/VBoxContainer/header/Control/headerContainer/HBoxContainer/back
	OPTIONS = $MarginContainer/VBoxContainer/header/Control/headerContainer/HBoxContainer/options
	PLAY = $MarginContainer/VBoxContainer/marginSelectContainer/container/selection/charListContainer/buttonPlayMargin/playButton

	# Connect all the buttons
	CHAR1.connect("pressed", self, "characterSelected", ["char1"])
	CHAR2.connect("pressed", self, "characterSelected", ["char2"])
	CHAR3.connect("pressed", self, "characterSelected", ["char3"])
	CHAR4.connect("pressed", self, "characterSelected", ["char4"])
	CHAR5.connect("pressed", self, "characterSelected", ["char5"])
	CHAR6.connect("pressed", self, "characterSelected", ["char6"])
	BACK.connect("pressed", self, "buttonHeader", ["back"])
	OPTIONS.connect("pressed", self, "buttonHeader", ["settings"])
	PLAY.connect("pressed", self, "buttonHeader", ["play"])

	# Default character selected
	characterSelected("char"+str(currentChar))

	var _anim_player = $MarginContainer/VBoxContainer/marginSelectContainer/container/character/marginCharRight/verticalAlignment/VBoxContainer/character
	#anim_player.texture = load("res://.import/true_size_1000.png-b6d6586ad26cd92d7c20aea1ae92f3fb.stex")


func _process(_delta):
	# Video player play on loop
	var _anim_player = $MarginContainer/VBoxContainer/marginSelectContainer/container/character/marginCharRight/verticalAlignment/VBoxContainer/character
	var stats = $MarginContainer/VBoxContainer/marginSelectContainer/container/character/marginCharRight/verticalAlignment/marginSkills

	var stat_size = stats.get_rect().size.y
	yWindow = get_viewport().size.y
	var _y = float(yWindow)*ratio-stat_size

	#var brick_texture = anim_player.Frames.GetFrame("blue", 0);
	#anim_player.set_size(Vector2(y,y))
	#anim_player.scale = y



# Set new skills value for the character
func _setTextureProgress(skill, value):
	skill.value = value

# Set the pic of the selected character
func _setTextureCharacter(_character):
	var _charSprite = $MarginContainer/VBoxContainer/marginSelectContainer/container/character/marginCharRight/verticalAlignment/VBoxContainer/character
	#charSprite.texture = character

#set the pic of the selected character version pas opti frame par frame
func _setAnimatedSpriteCharacter(video,nbFrames):
	var anim_player = $MarginContainer/VBoxContainer/marginSelectContainer/container/character/marginCharRight/verticalAlignment/VBoxContainer/character
	#anim_player.
	anim_player.texture.set_fps(20)
	anim_player.texture.set_frames(nbFrames)

	#toutes les images doivent avoir la même taille sinon certaines vont êtres déformées
	for i in range(0,nbFrames,2):
		var texture = TextureRect.new()
		texture = load("res://levels/selectChar/assets/"+ video + str(i) +".png")
		anim_player.texture.set_frame_texture(i,texture)

#set the gif of the selected character
func _setAnimatedGif(gif):
	var img = $MarginContainer/VBoxContainer/marginSelectContainer/container/character/marginCharRight/verticalAlignment/VBoxContainer/character
	img.texture = load("res://levels/selectChar/assets/char1/lully.gif")

func _setNameCharacter(name):
	var labelName = $MarginContainer/VBoxContainer/marginSelectContainer/container/character/marginCharRight/verticalAlignment/charaName
	labelName.set_text(str(name))

func _getCompetences():
	pass

#display the character selected and his stats
func characterSelected(character):
	if character == "char1":
		currentChar = SKIN_LULLABY
		_setTextureCharacter(CHARPIC1)
		_setTextureProgress(SKILL_1, 45)
		_setTextureProgress(SKILL_2, 78)
		_setTextureProgress(SKILL_3, 39)
		_setTextureProgress(SKILL_4, 27)
		_setNameCharacter("Claire Delalune")

		if(saveSettings._settings.jeu.anim == true): #si les animations sont désactivées
			_setAnimatedSpriteCharacter("char1/true_size_10",1)
		else:
			_setAnimatedSpriteCharacter("char1/true_size_10",90)

	if character == "char2":
		currentChar = SKIN_DISCO
		_setTextureCharacter(CHARPIC2)
		_setTextureProgress(SKILL_1, 68)
		_setTextureProgress(SKILL_2, 43)
		_setTextureProgress(SKILL_3, 87)
		_setTextureProgress(SKILL_4, 41)
		_setNameCharacter("Funky Franky")


		if(saveSettings._settings.jeu.anim == true):
			_setAnimatedSpriteCharacter("char2/mrdisco_1",1)
		else:
			_setAnimatedSpriteCharacter("char2/mrdisco_1",90)

	if character == "char3":
		currentChar = SKIN_ANGELA
		_setTextureCharacter(CHARPIC3)
		_setTextureProgress(SKILL_1, 21)
		_setTextureProgress(SKILL_2, 74)
		_setTextureProgress(SKILL_3, 32)
		_setTextureProgress(SKILL_4, 68)
		_setNameCharacter("Angela")

		if(saveSettings._settings.jeu.anim == true):
			_setAnimatedSpriteCharacter("char3/angela",1)
		else:
			_setAnimatedSpriteCharacter("char3/angela",90)


	if character == "char4":
		currentChar = SKIN_REGGAE
		#_setTextureCharacter(CHARPIC4)
		_setTextureProgress(SKILL_1, 20)
		_setTextureProgress(SKILL_2, 50)
		_setTextureProgress(SKILL_3, 30)
		_setTextureProgress(SKILL_4, 22)
		_setNameCharacter("Chill Bill")

		if(saveSettings._settings.jeu.anim == true):
			_setAnimatedSpriteCharacter("char4/reggae",1)
		else:
			_setAnimatedSpriteCharacter("char4/reggae",90)

	if character == "char5":
		currentChar = SKIN_METAL
		_setTextureCharacter(CHARPIC4)
		_setTextureProgress(SKILL_1, 23)
		_setTextureProgress(SKILL_2, 44)
		_setTextureProgress(SKILL_3, 17)
		_setTextureProgress(SKILL_4, 89)
		if(saveSettings._settings.jeu.anim == true):
			_setAnimatedSpriteCharacter("char5/metal",1)
		else:
			_setAnimatedSpriteCharacter("char5/metal",90)
		_setNameCharacter("Vega Punk")

	if character == "char6":
		currentChar = SKIN_ELECTRO
		_setTextureCharacter(CHARPIC4)
		_setTextureProgress(SKILL_1, 50)
		_setTextureProgress(SKILL_2, 20)
		_setTextureProgress(SKILL_3, 17)
		_setTextureProgress(SKILL_4, 65)
		if(saveSettings._settings.jeu.anim == true):
			_setAnimatedSpriteCharacter("char6/robot",1)
		else:
			_setAnimatedSpriteCharacter("char6/robot",90)
		
		_setNameCharacter("Daft Algan")


func buttonHeader(button_name):
	if button_name == "back":
		interfaces.loadNewScene(interfaces.SELECT_GAME_PATH)
	elif button_name == "settings":
		interfaces.loadNewScene(interfaces.SETTINGS_PATH)
	elif button_name == "play":
		if currentChar == SKIN_DEFAULT:
			currentChar = SKIN_DISCO
		gamestate.joinGameRequest(interfaces.NUMBER_OF_PLAYERS, interfaces.pseudo, currentChar)

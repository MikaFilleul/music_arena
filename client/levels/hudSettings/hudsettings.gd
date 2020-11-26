extends Control

# Declare member variables here. Examples:
#menu en haut

var backButton

var audioButton
var gameButton
var controlButton

var audioPage
var gamePage
var controlPage

var sound
var soundlabel
var soundimage

var music
var musiclabel
var musicimage

var toggleFullscreen
var animtoggle


#sauvegarde
var saveButton
var resetButton

var settings

var _settings = {
	"audio": {
		"son": 42.0 ,
		"musique": 42.0
	},
	"controles": {
		"gauche": 1,
		"droite": 1,
		"saut": 1
	},
	"jeu": {
		"anim":false ,
		"fullscreen":false
	}
}

# Called when the node enters the scene tree for the first time.
func _ready():
	
		
	audioButton = $VBoxContainer/main/settingsContainer/AsideMenu/VBoxContainer/listButton/Audio
	gameButton = $VBoxContainer/main/settingsContainer/AsideMenu/VBoxContainer/listButton/Jeu
	controlButton = $VBoxContainer/main/settingsContainer/AsideMenu/VBoxContainer/listButton/Controle
	
	audioPage = $VBoxContainer/main/settingsContainer/AsideDetails/MarginContainer/content/scrollContainer/HBoxContainer/listMenu/son
	gamePage = $VBoxContainer/main/settingsContainer/AsideDetails/MarginContainer/content/scrollContainer/HBoxContainer/listMenu/jeu
	controlPage = $VBoxContainer/main/settingsContainer/AsideDetails/MarginContainer/content/scrollContainer/HBoxContainer/listMenu/controles
	
	sound = $VBoxContainer/main/settingsContainer/AsideDetails/MarginContainer/content/scrollContainer/HBoxContainer/listMenu/son/son_slider/sound
	soundlabel = $VBoxContainer/main/settingsContainer/AsideDetails/MarginContainer/content/scrollContainer/HBoxContainer/listMenu/son/son_slider/percent
	soundimage = $VBoxContainer/main/settingsContainer/AsideDetails/MarginContainer/content/scrollContainer/HBoxContainer/listMenu/son/son_slider/textureound
	
	music = $VBoxContainer/main/settingsContainer/AsideDetails/MarginContainer/content/scrollContainer/HBoxContainer/listMenu/son/son_music/music
	musiclabel = $VBoxContainer/main/settingsContainer/AsideDetails/MarginContainer/content/scrollContainer/HBoxContainer/listMenu/son/son_music/percent
	musicimage = $VBoxContainer/main/settingsContainer/AsideDetails/MarginContainer/content/scrollContainer/HBoxContainer/listMenu/son/son_music/texturemusic

	saveButton = $VBoxContainer/main/settingsContainer/AsideDetails/MarginContainer/content/BottomButtons/apply
	resetButton = $VBoxContainer/main/settingsContainer/AsideMenu/VBoxContainer/resetButton/button

	toggleFullscreen = $VBoxContainer/main/settingsContainer/AsideDetails/MarginContainer/content/scrollContainer/HBoxContainer/listMenu/jeu/ecranToggle
	animtoggle = $VBoxContainer/main/settingsContainer/AsideDetails/MarginContainer/content/scrollContainer/HBoxContainer/listMenu/jeu/animToggle
	
	sound.connect("value_changed", self, "on_sound_slider_slided")
	music.connect("value_changed", self, "on_music_slider_slided")
		
	audioButton.connect("pressed", self, "settings_menu_button_pressed", ["Audio"])
	gameButton.connect("pressed", self, "settings_menu_button_pressed", ["Jeu"])
	controlButton.connect("pressed", self, "settings_menu_button_pressed", ["Controle"])
	
	saveButton.connect("pressed", self, "savePressed")
	resetButton.connect("pressed", self, "loadPressed")
	
	toggleFullscreen.connect("toggled",self, "fullScreenOn")
	
	#valeurs sauvegardées
	if(saveSettings.config.load(saveSettings.savePath) == OK):
		_settings = saveSettings.loadValue()
		#print("file found")
	else:
		#print("file not found")
		_settings = saveSettings.loadDefaultValue()
	#_settings = saveSettings.loadValue()
	
	sound.value = _settings.audio.son
	music.value = _settings.audio.musique 
	animtoggle.pressed = _settings.jeu.anim
	toggleFullscreen.pressed = _settings.jeu.fullscreen


#enregistre les valeurs dans le fichier savefile 
func savePressed():
	_settings.audio.son = sound.value
	_settings.audio.musique = music.value
	_settings.jeu.anim = animtoggle.pressed
	_settings.jeu.fullscreen = toggleFullscreen.pressed
	
	saveSettings.saveValue(_settings)
	var root = get_node(gamestate.GAMEPATH)
	if root.has_node(str(get_tree().get_network_unique_id())):
		root.get_node(str(get_tree().get_network_unique_id())+"/Music").setVolume()

func loadPressed():
	_settings = saveSettings.loadDefaultValue()
	
	#affichage sur les bouttons
	sound.value = _settings.audio.son
	music.value = _settings.audio.musique 
	animtoggle.pressed = _settings.jeu.anim
	toggleFullscreen.pressed = _settings.jeu.fullscreen
	#toggleFullscreen.pressed = get_node("/root/SaveSettings").loadValue("Values", "FullScreen")


func settings_menu_button_pressed(button_name):
	if button_name == "Audio":
		audioPage.visible = true
		gamePage.visible = false
		controlPage.visible = false
		
	elif button_name == "Jeu":
		audioPage.visible = false
		gamePage.visible = true
		controlPage.visible = false
		
	elif button_name == "Controle":
		
		audioPage.visible = false
		gamePage.visible = false
		controlPage.visible = true
		
		
#Valeurs des sliders
	
#Switch principal
func on_slider_slided(slider_name):

	
	if slider_name == "son":
		soundlabel.set_text(str(sound.value) + "%")
		
		if sound.value == 0.0:
			soundimage.texture = load("res://levels/settings/assets/speaker3.png")
		elif sound.value > 0 and sound.value < 60:
			soundimage.texture = load("res://levels/settings/assets/speaker2.png")
		else:
			soundimage.texture = load("res://levels/settings/assets/speaker.png")

	elif slider_name == "music":
		# print("Valeur du slider : ", music.value)
		musiclabel.set_text(str(music.value) + "%")
		
		if music.value == 0.0:
			musicimage.texture = load("res://levels/settings/assets/speaker3.png")
		elif music.value > 0 and music.value < 60:
			musicimage.texture = load("res://levels/settings/assets/speaker2.png")
		else:
			musicimage.texture = load("res://levels/settings/assets/speaker.png")


#signaux pour haque slider 

func on_sound_slider_slided(_value):
	on_slider_slided("son")

func on_music_slider_slided(_value):
	on_slider_slided("music")
	
func fullScreenOn(_value):
	# print(toggleFullscreen.pressed)
	if _value == true:
		OS.window_fullscreen = true
	elif _value == false:
		OS.window_fullscreen = false
		OS.set_window_maximized(true)
	

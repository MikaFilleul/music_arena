extends Control

var didacticiel
var play
var profile
var settings
var credits
var exit
var lienMenu
var logo

# Initial size = 408*175px
var rlogotmpX = float(300)/float(1024)
var rlogotmpY = float(129)/float(600)

var xWindow = 0
var yWindow = 0
# Initial button size = 350*79px
# First display size = 300*61
var ratioX = float(300)/float(1024)
var ratioY = float(79)/float(600)

var xButton
var yButton

func _ready():
	# If we are on this page, then the back of option lead here
	interfaces.LAST_WINDOWS_OPTIONS = interfaces.MAIN_MENU_PATH

	# Declare the buttons
	didacticiel = $homePage/sdfg/MarginContainer/menu/liensMenu/Didacticiel
	play = $homePage/sdfg/MarginContainer/menu/liensMenu/Play
	profile = $homePage/sdfg/MarginContainer/menu/liensMenu/Profile
	settings = $homePage/sdfg/MarginContainer/menu/liensMenu/Settings
	credits = $homePage/sdfg/MarginContainer/menu/liensMenu/Credits
	exit = $homePage/sdfg/MarginContainer/menu/liensMenu/Exit

	lienMenu = $homePage/sdfg/MarginContainer/menu/liensMenu
	logo = $homePage/sdfg/MarginContainer/menu/MusicArena

	# Connect all of the start menu buttons
	didacticiel.connect("pressed", self, "startMenuPressed", ["didacticiel"])
	play.connect("pressed", self, "startMenuPressed", ["play"])
	profile.connect("pressed", self, "startMenuPressed", ["profile"])
	settings.connect("pressed", self, "startMenuPressed", ["settings"])
	credits.connect("pressed", self, "startMenuPressed", ["credits"])
	exit.connect("pressed", self, "startMenuPressed", ["exit"])

	xWindow = get_viewport().size.x
	yWindow = get_viewport().size.y
	var x = xWindow*ratioX
	#float(xWindow)*ratioX
	var y = (float(79)*x)/float(350)
	var logoX = float(xWindow)*rlogotmpX
	var logoY = float(yWindow)*rlogotmpY
	logo.set_custom_minimum_size(Vector2(logoX,logoY))
	for blank_button in lienMenu.get_children():
		blank_button.set_custom_minimum_size(Vector2(x,y))
	var error = get_tree().get_root().connect("size_changed", self, "myfunc")
	if (error != OK):
		print("Error: %s" % error)

func myfunc():
	lienMenu = $homePage/sdfg/MarginContainer/menu/liensMenu
	logo = $homePage/sdfg/MarginContainer/menu/MusicArena

	if(get_viewport_rect().size.x != xWindow):
		xWindow = get_viewport_rect().size.x
		var x = float(xWindow)*ratioX
		var y = 0
		var logoX = float(xWindow)*rlogotmpX + 40
		var logoY = (float(175)*x)/float(408)
		logo.set_custom_minimum_size(Vector2(logoX,logoY))
		for child in lienMenu.get_children():

			y = (float(79)*x)/float(350)
			child.set_custom_minimum_size(Vector2(0,0))
			child.set_custom_minimum_size(Vector2(x,y))

func startMenuPressed(button_name):
	if button_name == "play":
		var fadeFond = $TextureRect4/fade
		fadeFond.play("fadeOut")
		var fadeChara = $TextureRect/fade
		fadeChara.play("fadeOut")
		var fadeOut = $homePage/fade
		fadeOut.play("fade")
		var t = Timer.new()
		t.set_wait_time(0.7)
		t.set_one_shot(true)
		self.add_child(t)
		t.start()
		yield(t, "timeout")
		interfaces.loadNewScene(interfaces.SELECT_GAME_PATH)
	elif button_name == "profile":
		var fadeFond = $TextureRect4/fade
		fadeFond.play("fadeOut")
		var fadeChara = $TextureRect/fade
		fadeChara.play("fadeOut")
		var fadeOut = $homePage/fade
		fadeOut.play("fade")
		var t = Timer.new()
		t.set_wait_time(1)
		t.set_one_shot(true)
		self.add_child(t)
		t.start()
		yield(t, "timeout")
		interfaces.loadNewScene(interfaces.PROFILE_PATH)
	elif button_name == "credits":
		var fadeFond = $TextureRect4/fade
		fadeFond.play("fadeOut")
		var fadeChara = $TextureRect/fade
		fadeChara.play("fadeOut")
		var fadeOut = $homePage/fade
		fadeOut.play("fade")
		var t = Timer.new()
		t.set_wait_time(1)
		t.set_one_shot(true)
		self.add_child(t)
		t.start()
		yield(t, "timeout")
		interfaces.loadNewScene(interfaces.CREDITS_PATH)
	elif button_name == "settings":
		var fadeFond = $TextureRect4/fade
		fadeFond.play("fadeOut")
		var fadeChara = $TextureRect/fade
		fadeChara.play("fadeOut")
		var fadeOut = $homePage/fade
		fadeOut.play("fade")
		var t = Timer.new()
		t.set_wait_time(1)
		t.set_one_shot(true)
		self.add_child(t)
		t.start()
		yield(t, "timeout")
		interfaces.loadNewScene(interfaces.SETTINGS_PATH)
	elif button_name == "exit":
		var fadeFond = $TextureRect4/fade
		fadeFond.play("fadeOut")
		var fadeChara = $TextureRect/fade
		fadeChara.play("fadeOut")
		var fadeOut = $homePage/fade
		fadeOut.play("fade")
		var t = Timer.new()
		t.set_wait_time(1)
		t.set_one_shot(true)
		self.add_child(t)
		t.start()
		yield(t, "timeout")
		get_tree().quit()

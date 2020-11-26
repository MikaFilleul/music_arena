extends Control

var BACK
var OPTIONS

var MEMOS
var CREDITS

var memosPage
var creditsPage

func _ready():
	interfaces.LAST_WINDOWS_OPTIONS = interfaces.CREDITS_PATH
	
	BACK = $MarginContainer/VBoxContainer/header/Control/headerContainer/HBoxContainer/back
	OPTIONS = $MarginContainer/VBoxContainer/header/Control/headerContainer/HBoxContainer/options
	MEMOS = $MarginContainer/VBoxContainer/main/profileContainer/asidePanel/listButton/memoButtons
	CREDITS = $MarginContainer/VBoxContainer/main/profileContainer/asidePanel/listButton/aboutUsButton
	memosPage = $MarginContainer/VBoxContainer/main/profileContainer/maininfoPanel/MarginContainer/maininfo/memos
	creditsPage = $MarginContainer/VBoxContainer/main/profileContainer/maininfoPanel/MarginContainer/maininfo/aboutUs
	
	
	BACK.connect("pressed", self, "buttonPressed", ["back"])
	OPTIONS.connect("pressed", self, "buttonPressed", ["settings"])
	MEMOS.connect("pressed", self, "buttonPressed", ["memo"])
	CREDITS.connect("pressed", self, "buttonPressed", ["credit"])


func buttonPressed(button_name):
	
	if button_name == "back":
		interfaces.loadNewScene(interfaces.MAIN_MENU_PATH)
	elif button_name == "settings":
		interfaces.loadNewScene(interfaces.SETTINGS_PATH)
	elif button_name == "memo":
		memosPage.visible = true
		creditsPage.visible = false
	elif button_name == "credit":
		memosPage.visible = false
		creditsPage.visible = true

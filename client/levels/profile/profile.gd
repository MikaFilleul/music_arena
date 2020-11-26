extends Control

var statButton
var succesButton
var PSEUDO
var BACK
var OPTIONS

# theme
var labelTheme = preload("res://levels/commons/themes/labelSkillFont.tres")
var titreTroph = preload("res://levels/commons/themes/titleTrophies.tres")
var undertitleTroph = preload("res://levels/commons/themes/descTrophies.tres")
# trophies
var TROPH1 = preload("res://levels/profile/assets/discotmp.png")
var TROPH2 = preload("res://levels/profile/assets/discotmp.png")
var TROPH3 = preload("res://levels/profile/assets/discotmp.png")
var TROPH4 = preload("res://levels/profile/assets/discotmp.png")


#pages à afficher
var statPage
var succesPage

# Called when the node enters the scene tree for the first time.
func _ready():
	interfaces.LAST_WINDOWS_OPTIONS = interfaces.PROFILE_PATH

	BACK = $MarginContainer/VBoxContainer/header/Control/headerContainer/HBoxContainer/back
	OPTIONS = $MarginContainer/VBoxContainer/header/Control/headerContainer/HBoxContainer/options
	statPage = $MarginContainer/VBoxContainer/main/profileContainer/maininfoPanel/MarginContainer/maininfo/statistiques
	succesPage = $MarginContainer/VBoxContainer/main/profileContainer/maininfoPanel/MarginContainer/maininfo/succes
	statButton = $MarginContainer/VBoxContainer/main/profileContainer/asidePanel/aside/stat
	succesButton = $MarginContainer/VBoxContainer/main/profileContainer/asidePanel/aside/succes
	PSEUDO = $MarginContainer/VBoxContainer/main/profileContainer/asidePanel/aside/pseudoContainer/VBoxContainer/nom

	PSEUDO.text = interfaces.pseudo

	BACK.connect("pressed", self, "buttonHeader", ["back"])
	OPTIONS.connect("pressed", self, "buttonHeader", ["settings"])
	statButton.connect("pressed", self, "profil_menu_button_pressed", ["stat"])
	succesButton.connect("pressed", self, "profil_menu_button_pressed", ["succes"])

	for i in range(0,15):
		displayMatchHistory("23/02/2020","Funky Franky","5th/25","5")
		displayTrophies("DeathMaster","Kill everyone",1)


func profil_menu_button_pressed(button_name):

	if button_name == "stat":
		print('stat')
		statPage.visible = true
		succesPage.visible = false

	elif button_name == "succes":
		print('succes')
		statPage.visible = false
		succesPage.visible = true

func displayMatchHistory(date,chara,rank,kill):
	var dates = $MarginContainer/VBoxContainer/main/profileContainer/maininfoPanel/MarginContainer/maininfo/statistiques/VBoxContainer/historyPanel/MarginContainer/historyContent/historyBlocContent/dates
	var characters = $MarginContainer/VBoxContainer/main/profileContainer/maininfoPanel/MarginContainer/maininfo/statistiques/VBoxContainer/historyPanel/MarginContainer/historyContent/historyBlocContent/characters
	var ranks = $MarginContainer/VBoxContainer/main/profileContainer/maininfoPanel/MarginContainer/maininfo/statistiques/VBoxContainer/historyPanel/MarginContainer/historyContent/historyBlocContent/ranks
	var kills = $MarginContainer/VBoxContainer/main/profileContainer/maininfoPanel/MarginContainer/maininfo/statistiques/VBoxContainer/historyPanel/MarginContainer/historyContent/historyBlocContent/kills

	var newDate = Label.new()
	var newChar = Label.new()
	var newRank = Label.new()
	var newKill = Label.new()

	newDate.set_text(date)
	newDate.set_h_size_flags(1)
	newDate.set_v_size_flags(4)
	newDate.set_theme(labelTheme)
	newDate.set_valign(1)
	newDate.set_align(1)

	newChar.set_text(chara)
	newChar.set_h_size_flags(1)
	newChar.set_v_size_flags(4)
	newChar.set_theme(labelTheme)
	newChar.set_valign(1)
	newChar.set_align(1)

	newRank.set_text(rank)
	newRank.set_h_size_flags(1)
	newRank.set_v_size_flags(4)
	newRank.set_theme(labelTheme)
	newRank.set_valign(1)
	newRank.set_align(1)

	newKill.set_text(kill)
	newKill.set_h_size_flags(1)
	newKill.set_v_size_flags(4)
	newKill.set_theme(labelTheme)
	newKill.set_valign(1)
	newKill.set_align(1)

	dates.add_child(newDate)
	characters.add_child(newChar)
	ranks.add_child(newRank)
	kills.add_child(newKill)


func displayTrophies(title,descr,idTexture):
	var trophies = $MarginContainer/VBoxContainer/main/profileContainer/maininfoPanel/MarginContainer/maininfo/succes/trophiesContainer/VBoxContainer

	var champion = HBoxContainer.new()
	var texture = TextureRect.new()
	var succes = VBoxContainer.new()
	var titre = Label.new()
	var desc = Label.new()

	titre.set_text(title)
	titre.set_theme(titreTroph)
	desc.set_text(descr)
	desc.set_theme(undertitleTroph)

	if idTexture == 1:
		texture.set_texture(TROPH1)
	elif idTexture == 2:
		texture.set_texture(TROPH2)
	elif idTexture == 3:
		texture.set_texture(TROPH3)
	elif idTexture == 4:
		texture.set_texture(TROPH4)
	texture.set_expand(true)
	texture.set_stretch_mode(6)
	texture.set_custom_minimum_size(Vector2(50,50))

	champion.set("custom_constants/separation", 10)

	succes.add_child(titre)
	succes.add_child(desc)
	champion.add_child(texture)
	champion.add_child(succes)
	trophies.add_child(champion)


func buttonHeader(button_name):
	if button_name == "back":
		interfaces.loadNewScene(interfaces.MAIN_MENU_PATH)
	elif button_name == "settings":
		interfaces.loadNewScene(interfaces.SETTINGS_PATH)

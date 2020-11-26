extends Control

var LOGO
var PANEL
var ROOT

# Initial size = 408*175px
var rlogotmpX = float(300)/float(1024)
var rlogotmpY = float(129)/float(600)

var xWindow = 0
var yWindow = 0
# Initial button size = 350*79px
# First display size = 300*61
var ratioX = float(300)/float(1024)
var ratioY = float(79)/float(600)
var ratioPanel = float(425)/float(1014)


func _ready():
	LOGO = $MarginContainer/VBoxContainer/MusicArena
	PANEL = $MarginContainer/VBoxContainer/Panel
	#ROOT = $Control
	
	xWindow = get_viewport().size.x
	yWindow = get_viewport().size.y
	var x = xWindow*ratioX
	#float(xWindow)*ratioX
	var y = (float(79)*x)/float(350)
	var logoX = float(xWindow)*rlogotmpX
	var logoY = float(yWindow)*rlogotmpY
	LOGO.set_custom_minimum_size(Vector2(logoX,logoY))
	var xPanel = float(xWindow)*ratioPanel
	PANEL.set_custom_minimum_size(Vector2(xPanel,50))
	var error = get_tree().get_root().connect("size_changed", self, "myfunc")
	
	#yield(gamestate, "gameFullyLoaded")
	#print("gameFullyLoaded")
	#ROOT.visible = false

func myfunc():
	LOGO = $MarginContainer/VBoxContainer/MusicArena
	PANEL = $MarginContainer/VBoxContainer/Panel

	if(get_viewport_rect().size.x != xWindow):
		xWindow = get_viewport_rect().size.x
		var x = float(xWindow)*ratioX
		var y = 0
		var logoX = float(xWindow)*rlogotmpX + 40
		var logoY = (float(175)*x)/float(408)
		var xPanel = float(xWindow)*ratioPanel
		LOGO.set_custom_minimum_size(Vector2(logoX,logoY))
		PANEL.set_custom_minimum_size(Vector2(xPanel,50))

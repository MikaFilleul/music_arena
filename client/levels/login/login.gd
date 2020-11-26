extends Control
#const SQLite = preload("res://lib/gdsqlite.gdns")

# Database variable
#var db = SQLite.new()

# Initial size = 408*175px
var rlogotmpX = float(200)/float(1024)
var rlogotmpY = float(130)/float(600)

# Window size
var xWindow = 0
var yWindow = 0
var ratioX = float(300)/float(1024)
var ratioY = float(79)/float(600)

# Variables
var LOGBUTTON
var EMAIL
var LOGIN
var PASSWD
var LOGO
var PANEL
var FORGOT
var CREATE
var ERROR

func _ready():

	# Server connection initialization
	#_client.create_client("91.121.81.74",5000)
	#get_tree().set_network_peer(_client)

	#_client.connect("connection_established", self, "_client_connected")
	#_client.connect("connection_error", self, "_client_disconnected")
	#_client.connect("connection_closed", self, "_client_disconnected")

	# Set the variables
	LOGBUTTON = $MarginContainer/pageLogin/loginZone/Panel/loginContainer/VBoxContainer/loginButton
	LOGO = $MarginContainer/pageLogin/MusicArena
	PANEL = $MarginContainer/pageLogin/loginZone/Panel
	CREATE = $MarginContainer/pageLogin/loginZone/Panel/loginContainer/VBoxContainer/subscribe
	FORGOT = $MarginContainer/pageLogin/loginZone/Panel/loginContainer/VBoxContainer/forgottenpassword

	LOGIN = $MarginContainer/pageLogin/loginZone/Panel/loginContainer/VBoxContainer/usernameArea
	PASSWD = $MarginContainer/pageLogin/loginZone/Panel/loginContainer/VBoxContainer/passwordArea
	ERROR = $MarginContainer/pageLogin/loginZone/Panel/loginContainer/VBoxContainer/errorArea

	xWindow = get_viewport().size.x
	yWindow = get_viewport().size.y
	var logoX = float(xWindow)*rlogotmpX
	var logoY = float(yWindow)*rlogotmpY
	LOGO.set_custom_minimum_size(Vector2(logoX,logoY))
	PANEL.set_custom_minimum_size(Vector2(400,PANEL.get_size().y))
	get_tree().get_root().connect("size_changed", self, "myfunc")

	# Connecting the buttons
	CREATE.connect("pressed", self, "loginPressed", ["subscribe"])
	FORGOT.connect("pressed", self, "loginPressed", ["forgot"])
	LOGBUTTON.connect("pressed", self, "loginPressed", ["connection"])

func loginPressed(label):
	if label == "subscribe" :
		print("subscribe")
		OS.shell_open("https://musicarena.pleuh.fr/index.php/user/signup")
	elif label == "forgot":
		print("oups")
		OS.shell_open("https://musicarena.pleuh.fr/index.php/user/forgot_password")
	elif label == "connection":
		if len(LOGIN.text) != 0:
			interfaces.pseudo = LOGIN.text
			loginFailureDisplay("")
			gamestate.loginRequest(LOGIN.text, PASSWD.text.sha256_text())
		else:
			loginFailureDisplay("Login can't be empty")


func loginFailureDisplay(text):
	ERROR.text = text


func myfunc():
	LOGO = $MarginContainer/pageLogin/MusicArena
	PANEL = $MarginContainer/pageLogin/loginZone/Panel

	if(get_viewport_rect().size.x != xWindow):
		xWindow = get_viewport_rect().size.x
		var x = xWindow*ratioX
		var logoX = float(xWindow)*rlogotmpX + 40
		var logoY = (float(175)*x)/float(408)
		LOGO.set_custom_minimum_size(Vector2(logoX,logoY))
		PANEL.set_custom_minimum_size(Vector2(400,PANEL.get_size().y))

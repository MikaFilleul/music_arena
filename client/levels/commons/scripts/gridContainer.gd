extends GridContainer

var charNumber = 18
var charPic = preload("res://levels/selectChar/assets/charPic.jpg")
var ROW = 4
var xWindow = 0
var ratio = float(448)/float(1024)

func _ready():
	xWindow = get_viewport().size.x
	var x = float(xWindow)*ratio - 40
	#print("xWindow = ",xWindow)
	#print("Ratio = ",ratio)
	#print("xContainer = ",x)
	#for i in range(1,charNumber):
	for blank_button in self.get_children():
		#var blank_button = TextureButton.new()
		#blank_button.set_normal_texture(charPic)
		#blank_button.set_expand(true)
		blank_button.set_custom_minimum_size(Vector2(x/ROW,x/ROW))
		#self.add_child(blank_button)
	var error = get_tree().get_root().connect("size_changed", self, "myfunc")
	if (error != OK):
		print("Error: %s" % error)

func myfunc():
	if(get_viewport_rect().size.x != xWindow):
		xWindow = get_viewport_rect().size.x
		var x = float(xWindow)*ratio - 40
		#print("-----------")
		#print("xWindow = ",xWindow)
		#print("xContainer = ",x)
		for child in self.get_children():
			#child.set_custom_minimum_size(Vector2(0,0))
			child.set_custom_minimum_size(Vector2((x/ROW),x/ROW))


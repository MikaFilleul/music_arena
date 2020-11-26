extends Button

# it didn't support passing in parameters

var colors = Gradient.new()

# and the colors need to have values from 0 to 1.0

var colors_array = [Color(1, .5, .5), Color(.5, .5, 1), Color(.5, .5, .5)]

var box_size = Vector2.ZERO



# supposing such a node in the world of some size

onready var box = get_node(".")



func _ready():
	print(box.get_size())
	var idx = 0.0
	var step = 1.0 / (len(colors_array) - 1)
	for color in colors_array:
		colors.add_point(idx, color)
		idx = min(idx + step, .999) # setting a color at point 1.0 failed to add it correctly to the end of the gradient	
		box_size = box.get_size()
		

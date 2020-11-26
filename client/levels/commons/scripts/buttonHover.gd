extends TextureButton

onready var TweenNode = get_node("Tween")
onready var button = get_node(".")

# Called when the node enters the scene tree for the first time.
func _ready():
	button.connect("mouse_entered", self, "tweenIn")
	button.connect("mouse_exited", self, "tweenOut")
	# print(button)


func tweenIn():
	# print("button hover")
	TweenNode.stop(TweenNode)
	TweenNode.interpolate_property(button, "rect_scale",
		Vector2(1,1), Vector2(1.1,1.1), 0.3,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	TweenNode.start()
	
func tweenOut():
	# print("button out")
	TweenNode.stop(TweenNode)
	TweenNode.interpolate_property(button, "rect_scale",
		Vector2(1.1,1.1), Vector2(1,1), 0.5,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	TweenNode.start()

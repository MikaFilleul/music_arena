extends Label

const GAMEPATH = "/root/game/"

var posId
var player

func _ready():
	posId = Vector3(0,0,0)
	player = get_node("../../")
	var my_id = get_tree().get_network_unique_id()

	if str(my_id) != str (player.get_name()) : 
		set_text(player.pseudo)


func _process(_delta):
	var cam = get_viewport().get_camera()
	if is_instance_valid(cam):
		posId.x = player.get_global_transform().origin.x - 0.75
		posId.y = player.get_global_transform().origin.y + 2.5
		var labelIdpos = cam.unproject_position(posId)
		set_position(labelIdpos)

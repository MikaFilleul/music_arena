extends Label

const GAMEPATH = "/root/game/"

var hp:int
var posPv
var player 
var my_id
var healVfx:Resource
var healSfx:Resource

func _ready():
	hp = 0
	posPv = Vector3(0,0,0)
	player = get_node("../../")
	my_id = get_tree().get_network_unique_id()
	healVfx = preload("res://entities/vfx/Heal.tscn")
	healSfx = preload("res://entities/sfx/healSfx.tscn")
	
	update_printed_hp(hp)


func _process(_delta):
	var cam = get_viewport().get_camera()
	if is_instance_valid(cam):
		posPv.x = player.get_global_transform().origin.x - 0.2
		posPv.y = player.get_global_transform().origin.y + 2
		var labelIdpos = cam.unproject_position(posPv)
		set_position(labelIdpos)


# update the current hp labels
func update_printed_hp(newHp:int):
	if (newHp < hp):
		var particle = healVfx.instance()
		player.get_node("Model").add_child(particle)
		var sound = healSfx.instance()
		player.get_node("Model").add_child(sound)
	hp = newHp
	if str(my_id) != str(player.get_name()):
		set_text(String(hp) + ' %')


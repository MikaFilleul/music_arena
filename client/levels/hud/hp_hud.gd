extends Label

const GAMEPATH = "/root/game/"

var hp:int 
var my_id

func _ready():
	hp = 0
	my_id = get_tree().get_network_unique_id()
	
	update_printed_hp(hp, my_id)
	


# update the current hp labels
func update_printed_hp(newHp:int, player_hurt_id): 
	if str(my_id) == str (player_hurt_id) : 
		hp = newHp
		set_text(String(hp) + ' %')


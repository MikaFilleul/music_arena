extends TextureRect

func _ready():
	var my_id = get_tree().get_network_unique_id()

	var skinId = gamestate.players[my_id]["skin"]
	var skins = {
		1: "res://models/pics/lullabyhud.png",
		2: "res://models/pics/discohud.png",
		3: "res://models/pics/angelahud.png",
		4: "res://models/pics/reaggehud.png",
		5: "res://models/pics/metalhud.png",
		6: "res://models/pics/electrohud.png"
	}

	if (skinId >= 1 && skinId <= 6):
		set_texture(load(skins[skinId]))

extends Label

func _ready():
	var my_id = get_tree().get_network_unique_id()

	set_text(gamestate.players[my_id]["pseudo"])


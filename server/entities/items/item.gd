extends Spatial

const player: = preload("res://entities/characters/player.gd")
const GAMEPATH = "/root/game/"

var id:int
var typeItem:int
var nearPlayer:Array = []

# Player is next to the item
func nearItem(idPlayer: int):
	return nearPlayer.has(str(idPlayer))


func _on_item_body_entered(body):
	if body is player:
		nearPlayer.append(body.name)


func _on_item_body_exited(body):
	if body is player:
		nearPlayer.erase(body.name)


func on_timeout_complete():
	gamestate.broadcastDeleteItem(id)
	queue_free()

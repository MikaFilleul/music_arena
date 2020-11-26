extends Control


func serverAlert(text:String):
	get_node("MarginContainer/VBoxContainer/MarginContainer/Main/create/Panel/infosContainer/HBoxContainer/testLabel").text = text

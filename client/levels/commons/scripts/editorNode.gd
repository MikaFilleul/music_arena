# make_editor_theme.gd
tool
extends EditorScript

func _run():
    var theme = get_editor_interface().get_base_control().theme
    ResourceSaver.save("res://editor_theme.tres", theme)
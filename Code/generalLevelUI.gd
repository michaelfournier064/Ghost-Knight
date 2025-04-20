extends Node3D

const SETTINGS_SCENE := preload("res://Scenes/Settings.tscn")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey \
			and event.keycode == KEY_ESCAPE \
			and event.pressed and not event.echo:
		get_tree().change_scene_to_packed(SETTINGS_SCENE)

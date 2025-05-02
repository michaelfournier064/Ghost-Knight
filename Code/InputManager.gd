# File: res://Code/InputManager.gd
extends Node

# Path to your level scene:
const LEVEL_SCENE_PATH := "res://Scenes/FirstLevel.tscn"

func _ready() -> void:
	# listen for any scene change
	get_tree().connect("scene_changed", Callable(self, "_on_scene_changed"))
	# also apply right now (in case you start in a non-level scene)
	_apply_mouse_mode(get_tree().current_scene)

func _on_scene_changed(new_scene: Node) -> void:
	_apply_mouse_mode(new_scene)

func _apply_mouse_mode(scene: Node) -> void:
	if scene and scene.scene_file_path == LEVEL_SCENE_PATH:
		# in level: capture/hide the mouse
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		# everywhere else: show the OS pointer
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

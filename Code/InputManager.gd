# File: res://Code/InputManager.gd
extends Node

# Path to your level scene:
const LEVEL_SCENE_PATH := "res://Scenes/FirstLevel.tscn"

# Track the previous pause state so we only re-apply once
var _prev_paused: bool = false

func _ready() -> void:
	# Always process, even when the SceneTree is paused
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_process(true)
	
	# Listen for scene changes
	get_tree().connect("scene_changed", Callable(self, "_on_scene_changed"))
	
	# Initial setup based on current scene and pause state
	_prev_paused = get_tree().paused
	_apply_mouse_mode(get_tree().current_scene)

func _process(_delta: float) -> void:
	# Detect pause/resume transitions
	if get_tree().paused != _prev_paused:
		_prev_paused = get_tree().paused
		_apply_mouse_mode(get_tree().current_scene)

func _on_scene_changed(new_scene: Node) -> void:
	_apply_mouse_mode(new_scene)

func _apply_mouse_mode(scene: Node) -> void:
	# When paused (e.g. settings menu open), always show the OS cursor
	if get_tree().paused:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		return

	# In your level scene: capture/hide the cursor
	if scene and scene.scene_file_path == LEVEL_SCENE_PATH:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		# Everywhere else: make the cursor visible
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

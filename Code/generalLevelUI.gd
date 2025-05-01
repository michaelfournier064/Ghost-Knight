# generalLevelUI.gd
extends Node3D

const SETTINGS_SCENE := preload("res://Scenes/Settings.tscn")
var _settings_ui: Control = null

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey \
	and event.keycode == KEY_ESCAPE \
	and event.pressed and not event.echo:
		if _settings_ui:
			return
		_settings_ui = SETTINGS_SCENE.instantiate()
		_settings_ui.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
		_settings_ui.connect("settings_closed", _on_settings_closed)
		get_tree().get_root().add_child(_settings_ui)
		get_tree().paused = true

func _on_settings_closed():
	get_tree().paused = false
	_settings_ui = null

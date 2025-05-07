# File: res://Code/generalLevelUI.gd
extends Node3D

const SETTINGS_SCENE = preload("res://Scenes/Settings.tscn")
const SkeletonEnemy  = preload("res://Code/EnemyBase.gd")

@onready var player: Player = $Player
var _settings_ui: Control = null

func _ready() -> void:
	# Disable auto-quit on window close
	get_tree().set_auto_accept_quit(false)
	# Catch Esc as raw input
	set_process_input(true)
	_assign_enemy_targets()

func _input(event: InputEvent) -> void:
	if get_tree().paused:
		return
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE and not event.echo:
		if _settings_ui:
			return
		get_tree().paused = true
		_settings_ui = SETTINGS_SCENE.instantiate()
		_settings_ui.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
		_settings_ui.connect("settings_closed", Callable(self, "_on_settings_closed"))
		get_tree().get_root().add_child(_settings_ui)

func _on_settings_closed() -> void:
	get_tree().paused = false
	_settings_ui.queue_free()
	_settings_ui = null

func _assign_enemy_targets() -> void:
	for child in get_children():
		if child is SkeletonEnemy:
			child.target_path = player.get_path()

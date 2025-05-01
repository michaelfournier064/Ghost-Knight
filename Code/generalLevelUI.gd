extends Node3D

const SETTINGS_SCENE    = preload("res://Scenes/Settings.tscn")
const ENEMY_SCENE       = preload("res://Scenes/Enemy.tscn")
# ← preload the script itself so GDScript knows the class
const SkeletonEnemy     = preload("res://Code/enemy.gd")

@onready var player: Player = $Player
var _settings_ui: Control = null

func _ready() -> void:
	_assign_enemy_targets()

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

func _assign_enemy_targets() -> void:
	for child in get_children():
		# now that SkeletonEnemy is preloaded, this check works
		if child is SkeletonEnemy:
			child.target_path = player.get_path()

func _spawn_enemy(at_position: Vector3) -> void:
	var e = ENEMY_SCENE.instantiate()
	add_child(e)  # Add to scene *first*
	e.global_transform = Transform3D(Basis(), at_position)  # Safe now
	e.target_path = player.get_path()

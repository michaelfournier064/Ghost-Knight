extends Node3D

const SETTINGS_SCENE    = preload("res://Scenes/Settings.tscn")
const ENEMY_SCENE       = preload("res://Scenes/Enemy.tscn")
const SkeletonEnemy     = preload("res://Code/enemy.gd")

@onready var player: Node3D = $Player
var _settings_ui: Control = null

@export var spawn_area: AABB = AABB(Vector3(-20, 0.5, -20), Vector3(40, 0, 40))  # Floor-wide bounds
var _spawn_timer: Timer
var _win_timer: Timer 

func _ready() -> void:
	_assign_enemy_targets()

	# spawning every 5s
	_spawn_timer = Timer.new()
	_spawn_timer.wait_time = 5.0
	_spawn_timer.one_shot = false
	_spawn_timer.timeout.connect(_spawn_enemy_randomly)
	add_child(_spawn_timer)
	_spawn_timer.start()

	# ← NEW: 7-minute win timer
	_win_timer = Timer.new()
	_win_timer.wait_time = 7 * 60.0
	_win_timer.one_shot = true
	_win_timer.timeout.connect(_on_win_timer_timeout)
	add_child(_win_timer)
	_win_timer.start()

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
		if child is SkeletonEnemy:
			child.target_path = player.get_path()

func _spawn_enemy(at_position: Vector3) -> void:
	var e = ENEMY_SCENE.instantiate()
	e.global_transform.origin = at_position
	if e is RogueSkeletonEnemy and is_instance_valid(player):
		e.target_path = player.get_path()
	add_child(e)


func _spawn_enemy_randomly() -> void:
	var rand_x = randf_range(spawn_area.position.x, spawn_area.position.x + spawn_area.size.x)
	var rand_z = randf_range(spawn_area.position.z, spawn_area.position.z + spawn_area.size.z)
	var pos = Vector3(rand_x, spawn_area.position.y, rand_z)
	_spawn_enemy(pos)

func _on_win_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://Scenes/WinScreen.tscn")

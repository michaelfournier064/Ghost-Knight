extends Node3D

const SETTINGS_SCENE = preload("res://Scenes/Settings.tscn")
const ENEMY_SCENE    = preload("res://Scenes/Enemy.tscn")
const WIN_SCENE      = preload("res://Scenes/WinScreen.tscn")

@export var spawn_area: AABB = AABB(Vector3(-20, 0.5, -20), Vector3(40, 0, 40))

@onready var player: Player = $Player
var _settings_ui: Control
var _spawn_timer: Timer
var _win_timer:   Timer

func _ready() -> void:
	GameStateManagerSingleton.load_state()
	print("** After reset+load in FirstLevel._ready():")
	print("   state[\"enemies\"]:", GameStateManagerSingleton.state["enemies"])
	print("   group count:", get_tree().get_nodes_in_group("enemies").size())
	_apply_full_state()
	_setup_timers()
	set_process_unhandled_input(true)

func _apply_full_state() -> void:
	var s = GameStateManagerSingleton.state

	# restore player position
	player.global_transform.origin = GameStateManagerSingleton._dict_to_vec3(s["player_pos"])

	# restore player health
	if s["player_health"] != null:
		player.Health = s["player_health"]
	else:
		player.Health = GameStateManagerSingleton.state.player_defaults.max_health

	# clear + respawn existing enemies
	for e in get_tree().get_nodes_in_group("enemies"):
		e.queue_free()

	for data in s["enemies"]:
		var e = ENEMY_SCENE.instantiate()
		e.target_path = player.get_path()
		# 1) add to scene tree first…
		add_child(e)
		# 2) …then position and restore health
		e.global_transform.origin = Vector3(data.pos.x, data.pos.y, data.pos.z)
		e.health = data.health

func _setup_timers() -> void:
	var s = GameStateManagerSingleton.state

	if _spawn_timer:
		_spawn_timer.queue_free()
	_spawn_timer = Timer.new()
	_spawn_timer.one_shot = false
	_spawn_timer.wait_time = s["spawn_interval"]
	_spawn_timer.timeout.connect(_on_spawn_timer)
	add_child(_spawn_timer)
	_spawn_timer.start()

	if _win_timer:
		_win_timer.queue_free()
	_win_timer = Timer.new()
	_win_timer.one_shot = true
	var remaining = s["win_time"] - s["elapsed_time"]
	_win_timer.wait_time = max(remaining, 0.0)
	_win_timer.timeout.connect(_on_win)
	add_child(_win_timer)
	_win_timer.start()

func _process(delta: float) -> void:
	GameStateManagerSingleton.state["elapsed_time"] += delta

func _on_spawn_timer() -> void:
	var s = GameStateManagerSingleton.state
	var ratio = min(s["elapsed_time"] / s["win_time"], 1.0)
	var interval = lerp(s["spawn_interval"], s["min_spawn_interval"], ratio)
	var speed_factor = lerp(s["enemy_speed_factor"], s["max_speed_factor"], ratio)

	var pos = Vector3(
		randf_range(spawn_area.position.x, spawn_area.position.x + spawn_area.size.x),
		spawn_area.position.y,
		randf_range(spawn_area.position.z, spawn_area.position.z + spawn_area.size.z)
	)

	var e = ENEMY_SCENE.instantiate()
	e.target_path = player.get_path()
	# add before moving it
	add_child(e)
	e.global_transform.origin = pos
	# override the default speed if you like
	e.speed = speed_factor * player.base_speed

	# update spawn interval in state
	s["spawn_interval"] = interval
	GameStateManagerSingleton.save_state()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE and not event.echo:
		_save_full_state()
		GameStateManagerSingleton.save_state()
		get_tree().paused = true
		_settings_ui = SETTINGS_SCENE.instantiate()
		_settings_ui.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
		_settings_ui.connect("settings_closed", Callable(self, "_on_settings_closed"))
		get_tree().get_root().add_child(_settings_ui)

func _on_settings_closed() -> void:
	get_tree().paused = false
	_settings_ui.queue_free()
	_settings_ui = null
	GameStateManagerSingleton.load_state()
	_setup_timers()

func _on_win() -> void:
	# Call reset_state() on the autoload instance instead of as a static
	var gsm = get_node("/root/GameStateManagerSingleton")
	gsm.reset_state()
	get_tree().change_scene_to_file("res://Scenes/WinScreen.tscn")

func _save_full_state() -> void:
	var s = GameStateManagerSingleton.state
	s["player_pos"] = GameStateManagerSingleton._vec3_to_dict(player.global_transform.origin)
	s["player_health"] = player.Health
	s["enemies"].clear()
	for e in get_tree().get_nodes_in_group("enemies"):
		s["enemies"].append({
			"pos":    GameStateManagerSingleton._vec3_to_dict(e.global_transform.origin),
			"health": e.health
		})
	GameStateManagerSingleton.save_state()
	print("Saved full state to disk.")

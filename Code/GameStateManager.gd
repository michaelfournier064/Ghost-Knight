# File: res://Code/GameStateManager.gd
extends Node
class_name GameStateManagerSingleton

const STATE_PATH := "user://gamestate.json"
var target_level: String = "Graveyard"

static var state := {
	"spawn_interval":     5.0,
	"min_spawn_interval": 1.0,
	"enemy_speed_factor": 0.75,
	"max_speed_factor":   0.9,
	"win_time":           7 * 60.0,

	"player_defaults": {
		"max_health":      10,
		"regen_interval":  30.0,
		"base_speed":      7.0,
		"sprint_speed":    10.0,
		"jump_velocity":   4.5,
		"dash_strength":   15.0,
		"attack_cooldown": 0,
		"input_left":      "Left",
		"input_right":     "Right",
		"input_forward":   "Forward",
		"input_back":      "Back",
		"input_jump":      "Jump",
		"input_sprint":    "Sprint",
		"input_dash":      "Dash",
		"input_attack":    "Attack"
	},

	"enemy_defaults": {
		"speed":           4.0,
		"attack_cooldown": 1.0,
		"attack_range":    2.5,
		"max_health":      2
	},

	"elapsed_time":   0.0,
	"player_pos":     { "x": 0.0, "y": 0.0, "z": 0.0 },
	"player_health":  null,
	"enemies":        []
}

func _ready() -> void:
	ensure_default_save()
	load_state()

static func ensure_default_save() -> void:
	if not FileAccess.file_exists(STATE_PATH):
		save_state()

static func load_state() -> void:
	var f = FileAccess.open(STATE_PATH, FileAccess.READ)
	if not f:
		push_warning("No save file, using defaults.")
		return
	var txt = f.get_as_text()
	f.close()

	var json = JSON.new()
	if json.parse(txt) == OK and typeof(json.get_data()) == TYPE_DICTIONARY:
		state = json.get_data()
		print("-- load_state: enemies =", state["enemies"].size())
	else:
		push_warning("Invalid JSON; resetting runtime state.")
		_clear_runtime()

static func save_state() -> void:
	var f = FileAccess.open(STATE_PATH, FileAccess.WRITE)
	if not f:
		push_error("Could not open save file.")
		return
	f.store_string(JSON.stringify(state))
	f.close()

func reset_state() -> void:
	if Engine.get_main_loop() is SceneTree:
		for e in Engine.get_main_loop().get_nodes_in_group("enemies"):
			e.queue_free()
	_clear_runtime()
	save_state()
	print("-- reset_state complete; saved cleared state --")

static func _clear_runtime() -> void:
	state["elapsed_time"]        = 0.0
	state["player_pos"]          = { "x": 0.0, "y": 0.0, "z": 0.0 }
	state["player_health"]       = null
	state["enemies"]             = []
	state["spawn_interval"]      = 5.0
	state["min_spawn_interval"]  = 1.0
	state["enemy_speed_factor"]  = 0.75
	state["max_speed_factor"]    = 0.9

static func _vec3_to_dict(v: Vector3) -> Dictionary:
	return { "x": v.x, "y": v.y, "z": v.z }

static func _dict_to_vec3(d: Dictionary) -> Vector3:
	return Vector3(d.get("x", 0.0), d.get("y", 0.0), d.get("z", 0.0))

# File: res://Code/SettingsLoaderSingleton.gd
extends Node
class_name SettingsLoaderSingleton

const CONFIG_FILE := "user://settings.cfg"

# Default audio & key mappings
const DEFAULT_AUDIO := {
	"master": 0.2,
	# "music": 1.0,
	# "sfx":   1.0,
}

const DEFAULT_KEYS := {
	"Left":    KEY_A,
	"Right":   KEY_D,
	"Forward": KEY_W,
	"Back":     KEY_S,
	"Jump":     KEY_SPACE,
	"Sprint":   KEY_SHIFT,
	"Dash":     KEY_Q,
	"Attack":   MOUSE_BUTTON_LEFT,
}

func _ready() -> void:
	load_settings()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_settings()
		get_tree().quit()

static func load_settings() -> void:
	var cfg = ConfigFile.new()
	var err = cfg.load(CONFIG_FILE)
	if err != OK:
		_seed_defaults_static(cfg)
		cfg.save(CONFIG_FILE)
		
	if cfg.has_section("audio"):
		for key in DEFAULT_AUDIO.keys():
			var v = float(cfg.get_value("audio", key, DEFAULT_AUDIO[key]))
			AudioServer.set_bus_volume_db(
				AudioServer.get_bus_index(key.capitalize()),
				linear_to_db(v)
			)
	
	if cfg.has_section("keys"):
		for action in cfg.get_section_keys("keys"):
			var data = cfg.get_value("keys", action)
			_apply_input_event_static(action, data)

static func save_settings() -> void:
	var cfg = ConfigFile.new()
	cfg.load(CONFIG_FILE)
	
	for key in DEFAULT_AUDIO.keys():
		var db = AudioServer.get_bus_volume_db(AudioServer.get_bus_index(key.capitalize()))
		cfg.set_value("audio", key, db_to_linear(db))
	
	for action in DEFAULT_KEYS.keys():
		var evs = InputMap.action_get_events(action)
		if evs.size() > 0:
			var e = evs[0]
			var enc = {}
			if e is InputEventKey:
				enc = {"type":"key",   "code": e.keycode}
			elif e is InputEventMouseButton:
				enc = {"type":"mouse", "button": e.button_index}
			cfg.set_value("keys", action, enc)
	
	cfg.save(CONFIG_FILE)

static func _seed_defaults_static(cfg: ConfigFile) -> void:
	for key in DEFAULT_AUDIO.keys():
		cfg.set_value("audio", key, DEFAULT_AUDIO[key])
	for action in DEFAULT_KEYS.keys():
		var enc = {"type":"key", "code": DEFAULT_KEYS[action]}
		cfg.set_value("keys", action, enc)

static func _apply_input_event_static(action: String, data) -> void:
	InputMap.action_erase_events(action)
	var ev: InputEvent = null
	if typeof(data) == TYPE_DICTIONARY:
		if data.get("type", "") == "key":
			ev = InputEventKey.new()
			ev.keycode = data.code
			ev.physical_keycode = data.code
		elif data.get("type", "") == "mouse":
			ev = InputEventMouseButton.new()
			ev.button_index = data.button
			ev.pressed = true
	if ev:
		InputMap.action_add_event(action, ev)

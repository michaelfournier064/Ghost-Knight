extends Node

const CONFIG_FILE := "user://settings.cfg"

func _ready() -> void:
	load_settings()               # load as soon as the game starts

# -------------------------------------------------------------
#  Catch Alt-F4 / window close → save & quit
# -------------------------------------------------------------
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_settings()
		get_tree().quit()

# ------------------------------------------------------------- #
#  LOAD
# ------------------------------------------------------------- #
func load_settings() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(CONFIG_FILE) != OK:
		return                                    # first run

	# ---- audio ----
	if cfg.has_section("audio"):
		var bus_map := {"master":"Master", "music":"Music", "sfx":"SFX"}
		for key in bus_map.keys():
			var v := float(cfg.get_value("audio", key, 1.0))
			AudioServer.set_bus_volume_db(
				AudioServer.get_bus_index(bus_map[key]), linear_to_db(v))

	# ---- keys ----
	if cfg.has_section("keys"):
		for action in cfg.get_section_keys("keys"):
			var data : Variant = cfg.get_value("keys", action)
			InputMap.action_erase_events(action)

			var ev : InputEvent = null
			if typeof(data) == TYPE_DICTIONARY:
				match data.get("type", ""):
					"key":
						ev = InputEventKey.new()
						ev.physical_keycode = int(data.get("code", 0))
					"mouse":
						ev = InputEventMouseButton.new()
						ev.button_index = int(data.get("button", 1))
			elif typeof(data) == TYPE_INT:          # legacy integer format
				ev = InputEventKey.new()
				ev.physical_keycode = int(data)

			if ev:
				InputMap.action_add_event(action, ev)

# ------------------------------------------------------------- #
#  SAVE
# ------------------------------------------------------------- #
func save_settings() -> void:
	var cfg := ConfigFile.new()

	# current bus volumes
	cfg.set_value("audio", "master",
		db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))))
	cfg.set_value("audio", "music",
		db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music"))))
	cfg.set_value("audio", "sfx",
		db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX"))))

	# first event for every registered action
	for action in InputMap.get_actions():
		var evs := InputMap.action_get_events(action)
		if evs.is_empty():
			continue
		var e := evs[0]
		var enc := {}
		if e is InputEventKey:
			enc = {"type":"key", "code":e.physical_keycode}
		elif e is InputEventMouseButton:
			enc = {"type":"mouse", "button":e.button_index}
		cfg.set_value("keys", action, enc)

	cfg.save(CONFIG_FILE)
	print("Settings saved →", CONFIG_FILE)

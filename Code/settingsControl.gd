extends Control

@onready var returnMainMenu : Button            = $backGroundImage/ReturnSaveVBoxContainer/ReturnMainMenuButton
@onready var saveChanges     : Button            = $backGroundImage/ReturnSaveVBoxContainer/SaveChangesButton
@onready var click_sound     : AudioStreamPlayer = $backGroundImage/clickSound

# ─── AUDIO SLIDERS ─────────────────────────────────────────────
@onready var master_slider : HSlider = $backGroundImage/VBoxContainer/VBoxContainer/MasterVolumeContainer/MasterVolumeSlider
@onready var music_slider  : HSlider = $backGroundImage/VBoxContainer/VBoxContainer/MusicVolumeContainer/MusicVolumeSlider
@onready var sfx_slider    : HSlider = $backGroundImage/VBoxContainer/VBoxContainer/SfxVolumeContainer/SfxVolumeSlider

const CONFIG_FILE := "user://settings.cfg"

# ---------------------------------------------------------------------------
#  INPUT‑ACTIONS : keep in sync with Player‑Controller.gd exported variables
# ---------------------------------------------------------------------------
const ACTIONS := {
	"Left":    KEY_A,
	"Right":   KEY_D,
	"Forward": KEY_W,
	"Back":    KEY_S,
	"Jump":    KEY_SPACE,
	"Sprint":  KEY_SHIFT,
	"Dash":    KEY_Q,
	"Attack":  {"mouse": MOUSE_BUTTON_LEFT},
	"freefly": KEY_F,
}

# ===========================================================================

func _ready() -> void:
	returnMainMenu.pressed.connect(_on_returnMainMenu_pressed)
	saveChanges.pressed.connect(_on_saveChanges_pressed)
	returnMainMenu.mouse_entered.connect(_on_button_mouse_entered)
	saveChanges.mouse_entered.connect(_on_button_mouse_entered)

	_ensure_default_keys()
	_connect_volume_sliders()
	_load_settings()

# ---------------------------------------------------------------------------
#  BUTTON HANDLERS
# ---------------------------------------------------------------------------
func _on_returnMainMenu_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/TitleScreen.tscn")

func _on_saveChanges_pressed() -> void:
	_save_settings()
	print("Settings saved →", CONFIG_FILE)

func _on_button_mouse_entered() -> void:
	if click_sound.playing:
		click_sound.stop()
	click_sound.play()

# ---------------------------------------------------------------------------
#  AUDIO
# ---------------------------------------------------------------------------
func _connect_volume_sliders() -> void:
	master_slider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")))
	music_slider.value  = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music")))
	sfx_slider.value    = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX")))

	master_slider.value_changed.connect(_on_master_volume_changed)
	music_slider.value_changed.connect(_on_music_volume_changed)
	sfx_slider.value_changed.connect(_on_sfx_volume_changed)

func _on_master_volume_changed(v: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(v))

func _on_music_volume_changed(v: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(v))

func _on_sfx_volume_changed(v: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(v))

# ---------------------------------------------------------------------------
#  INPUT‑ACTION HOUSEKEEPING
# ---------------------------------------------------------------------------
func _ensure_default_keys() -> void:
	for action_name in ACTIONS.keys():
		if not InputMap.has_action(action_name):
			InputMap.add_action(action_name)

		var events := InputMap.action_get_events(action_name)
		if events.is_empty():
			var default_val = ACTIONS[action_name]
			var ev : InputEvent = null
			match typeof(default_val):
				TYPE_INT:
					ev = InputEventKey.new()
					ev.physical_keycode = int(default_val)
				TYPE_DICTIONARY:
					if default_val.has("mouse"):
						ev = InputEventMouseButton.new()
						ev.button_index = int(default_val["mouse"])
			if ev:
				InputMap.action_add_event(action_name, ev)

# ---------------------------------------------------------------------------
#  SAVE / LOAD
# ---------------------------------------------------------------------------
func _save_settings() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("audio", "master", master_slider.value)
	cfg.set_value("audio", "music",  music_slider.value)
	cfg.set_value("audio", "sfx",    sfx_slider.value)

	for action_name in ACTIONS.keys():
		var events := InputMap.action_get_events(action_name)
		if events.is_empty():
			continue
		var e := events[0]
		var enc
		if e is InputEventKey:
			enc = {"type": "key", "code": e.physical_keycode}
		elif e is InputEventMouseButton:
			enc = {"type": "mouse", "button": e.button_index}
		else:
			continue
		cfg.set_value("keys", action_name, enc)

	var err := cfg.save(CONFIG_FILE)
	if err != OK:
		push_error("⚠ Could not write settings file: " + str(err))

func _load_settings() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(CONFIG_FILE) != OK:
		return

	if cfg.has_section("audio"):
		var m  = cfg.get_value("audio", "master", master_slider.value)
		var mu = cfg.get_value("audio", "music",  music_slider.value)
		var s  = cfg.get_value("audio", "sfx",    sfx_slider.value)

		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(m))
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"),  linear_to_db(mu))
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"),    linear_to_db(s))

		master_slider.value = m
		music_slider.value  = mu
		sfx_slider.value    = s

	if cfg.has_section("keys"):
		for action_name in cfg.get_section_keys("keys"):
			var data = cfg.get_value("keys", action_name, null)
			if data == null:
				continue
			InputMap.action_erase_events(action_name)
			var ev : InputEvent = null
			if typeof(data) == TYPE_DICTIONARY and data.has("type"):
				match data["type"]:
					"key":
						ev = InputEventKey.new()
						ev.physical_keycode = int(data["code"])
					"mouse":
						ev = InputEventMouseButton.new()
						ev.button_index = int(data["button"])
			elif typeof(data) == TYPE_INT:
				ev = InputEventKey.new()
				ev.physical_keycode = int(data)
			if ev:
				InputMap.action_add_event(action_name, ev)

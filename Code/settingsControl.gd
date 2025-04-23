extends Control

@onready var returnMainMenu : Button            = $backGroundImage/ReturnSaveVBoxContainer/ReturnMainMenuButton
@onready var saveChanges     : Button            = $backGroundImage/ReturnSaveVBoxContainer/SaveChangesButton
@onready var click_sound     : AudioStreamPlayer = $backGroundImage/clickSound

@onready var master_slider : HSlider = $backGroundImage/MainVBox/AudioVBox/MasterVolumeContainer/MasterVolumeSlider
@onready var music_slider  : HSlider = $backGroundImage/MainVBox/AudioVBox/MusicVolumeContainer/MusicVolumeSlider
@onready var sfx_slider    : HSlider = $backGroundImage/MainVBox/AudioVBox/SfxVolumeContainer/SfxVolumeSlider

const ACTIONS := {
	"Left": KEY_A,
	"Right": KEY_D,
	"Forward": KEY_W,
	"Back": KEY_S,
	"Jump": KEY_SPACE,
	"Sprint": KEY_SHIFT,
	"Dash": KEY_Q,
	"Attack": {"mouse": MOUSE_BUTTON_LEFT},
	"Freefly": KEY_F,
}

# ─────────────── READY ───────────────
func _ready() -> void:
	returnMainMenu.pressed.connect(_on_returnMainMenu_pressed)
	saveChanges.pressed.connect(_on_saveChanges_pressed)
	returnMainMenu.mouse_entered.connect(_on_button_mouse_entered)
	saveChanges.mouse_entered.connect(_on_button_mouse_entered)

	_ensure_default_keys()
	_connect_volume_sliders()
	_sync_gui_to_current_settings()

# ────────── BUTTON CALLBACKS ─────────
func _on_returnMainMenu_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/TitleScreen.tscn")

func _on_saveChanges_pressed() -> void:
	SettingsLoader.save_settings()
	print("Settings saved →", SettingsLoader.CONFIG_FILE)

func _on_button_mouse_entered() -> void:
	if click_sound.playing:
		click_sound.stop()
	click_sound.play()

# ─────────────── AUDIO ───────────────
func _connect_volume_sliders() -> void:
	var tree := AudioServer
	master_slider.value = db_to_linear(tree.get_bus_volume_db(tree.get_bus_index("Master")))
	music_slider.value  = db_to_linear(tree.get_bus_volume_db(tree.get_bus_index("Music")))
	sfx_slider.value    = db_to_linear(tree.get_bus_volume_db(tree.get_bus_index("SFX")))

	master_slider.value_changed.connect(_on_master_volume_changed)
	music_slider.value_changed.connect(_on_music_volume_changed)
	sfx_slider.value_changed.connect(_on_sfx_volume_changed)

func _on_master_volume_changed(v: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(v))

func _on_music_volume_changed(v: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(v))

func _on_sfx_volume_changed(v: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(v))

# ─────── DEFAULT KEY SETUP ───────
func _ensure_default_keys() -> void:
	for action_name in ACTIONS.keys():
		if not InputMap.has_action(action_name):
			InputMap.add_action(action_name)

		if InputMap.action_get_events(action_name).is_empty():
			var def_val : Variant = ACTIONS[action_name]
			var ev : InputEvent = null
			match typeof(def_val):
				TYPE_INT:
					ev = InputEventKey.new()
					ev.physical_keycode = int(def_val)
				TYPE_DICTIONARY:
					if def_val.has("mouse"):
						ev = InputEventMouseButton.new()
						ev.button_index = int(def_val["mouse"])
			if ev:
				InputMap.action_add_event(action_name, ev)

# ───────── GUI SYNC (no file I/O) ─────────
func _sync_gui_to_current_settings() -> void:
	var tree := AudioServer
	master_slider.value = db_to_linear(tree.get_bus_volume_db(tree.get_bus_index("Master")))
	music_slider.value  = db_to_linear(tree.get_bus_volume_db(tree.get_bus_index("Music")))
	sfx_slider.value    = db_to_linear(tree.get_bus_volume_db(tree.get_bus_index("SFX")))

	for btn in get_tree().get_nodes_in_group("key_remap_button"):
		if btn.has_method("_refresh_caption"):
			btn._refresh_caption()

extends Control

@onready var returnMainMenu : Button            = $backGroundImage/ReturnSaveVBoxContainer/ReturnMainMenuButton
@onready var returnToGame   : Button            = $backGroundImage/ReturnSaveVBoxContainer/ReturnToGameButton
@onready var saveChanges    : Button            = $backGroundImage/ReturnSaveVBoxContainer/SaveChangesButton
@onready var click_sound    : AudioStreamPlayer = $backGroundImage/clickSound

@onready var master_slider  : HSlider           = $backGroundImage/MainVBox/AudioVBox/MasterVolumeContainer/MasterVolumeSlider
# (music & sfx sliders commented out for now)

signal settings_closed

const ACTIONS := {
	"Left": KEY_A,
	"Right": KEY_D,
	"Forward": KEY_W,
	"Back": KEY_S,
	"Jump": KEY_SPACE,
	"Sprint": KEY_SHIFT,
	"Dash": KEY_Q,
}

func _ready() -> void:
	# only show “Return to Game” if the tree is paused
	returnToGame.visible = get_tree().paused

	_connect_volume_sliders()
	_ensure_default_keys()
	_sync_gui_to_current_settings()

	returnMainMenu.pressed.connect(_on_return_main_menu_button_pressed)
	returnToGame.pressed.connect(_on_return_to_game_button_pressed)
	saveChanges.pressed.connect(_on_save_changes_pressed)

func _on_return_main_menu_button_pressed() -> void:
	click_sound.play()
	get_tree().paused = false
	emit_signal("settings_closed")
	get_tree().change_scene_to_file("res://Scenes/TitleScreen.tscn")
	queue_free()

func _on_return_to_game_button_pressed() -> void:
	click_sound.play()
	get_tree().paused = false
	emit_signal("settings_closed")
	queue_free()

func _on_save_changes_pressed() -> void:
	click_sound.play()
	SettingsLoader.save_settings()
	print("Settings saved →", SettingsLoader.CONFIG_FILE)

func _on_button_mouse_entered() -> void:
	if click_sound.playing:
		click_sound.stop()
	click_sound.play()

# ───────── AUDIO ────────────
func _connect_volume_sliders() -> void:
	var tree := AudioServer
	master_slider.value = db_to_linear(tree.get_bus_volume_db(tree.get_bus_index("Master")))
	master_slider.value_changed.connect(_on_master_volume_changed)

func _on_master_volume_changed(v: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(v))

# ─── DEFAULT KEY SETUP ─────
func _ensure_default_keys() -> void:
	for action_name in ACTIONS.keys():
		if not InputMap.has_action(action_name):
			InputMap.add_action(action_name)
		if InputMap.action_get_events(action_name).is_empty():
			var ev = InputEventKey.new()
			ev.physical_keycode = int(ACTIONS[action_name])
			InputMap.action_add_event(action_name, ev)

# ─── GUI SYNC ──────────────
func _sync_gui_to_current_settings() -> void:
	var tree := AudioServer
	master_slider.value = db_to_linear(tree.get_bus_volume_db(tree.get_bus_index("Master")))

	for btn in get_tree().get_nodes_in_group("key_remap_button"):
		if btn.has_method("_refresh_caption"):
			btn._refresh_caption()

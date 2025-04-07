extends Control

@onready var returnMainMenu: Control = $backGroundImage/ReturnSaveVBoxContainer/ReturnMainMenuButton
@onready var saveChanges: Control = $backGroundImage/ReturnSaveVBoxContainer/SaveChangesButton
@onready var click_sound: AudioStreamPlayer = $backGroundImage/clickSound

const ACTIONS := {
	"jump": KEY_SPACE,
	"sprint": KEY_SHIFT
}

func _ready() -> void:
	# Connect signals using Callables.
	returnMainMenu.connect("pressed", Callable(self, "_on_returnMainMenu_pressed"))
	saveChanges.connect("pressed", Callable(self, "_on_saveChanges_pressed"))
	# Optionally, connect mouse_entered signals for playing a click sound.
	returnMainMenu.connect("mouse_entered", Callable(self, "_on_button_mouse_entered"))
	saveChanges.connect("mouse_entered", Callable(self, "_on_button_mouse_entered"))
	
	# Ensure default keys and connect volume sliders.
	_ensure_default_keys()
	_connect_volume_sliders()

func _on_returnMainMenu_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/TitleScreen.tscn")
	print("Return to main menu button pressed.")

func _on_saveChanges_pressed() -> void:
	print("Save changes button pressed.")
	# Update query to save all settings data goes here.

func _on_button_mouse_entered() -> void:
	if click_sound.playing:
		click_sound.stop()
	click_sound.play()

	_ensure_default_keys()
	_connect_volume_sliders()

func _ensure_default_keys() -> void:
	for action_name in ACTIONS.keys():
		if not InputMap.has_action(action_name):
			InputMap.add_action(action_name)
		var events = InputMap.action_get_events(action_name)
		if events.is_empty():
			var ev := InputEventKey.new()
			ev.physical_keycode = ACTIONS[action_name]
			InputMap.action_add_event(action_name, ev)

func _connect_volume_sliders() -> void:
	var master_slider = $backGroundImage/VBoxContainer/MasterVolumeContainer/MasterVolumeSlider
	var music_slider  = $backGroundImage/VBoxContainer/MusicVolumeContainer/MusicVolumeSlider
	var sfx_slider    = $backGroundImage/VBoxContainer/SfxVolumeContainer/SfxVolumeSlider

	# Set initial slider values based on current AudioServer state.
	master_slider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")))
	music_slider.value  = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music")))
	sfx_slider.value    = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX")))

	# Connect sliders using dedicated callbacks.
	master_slider.value_changed.connect(Callable(self, "_on_master_volume_changed"))
	music_slider.value_changed.connect(Callable(self, "_on_music_volume_changed"))
	sfx_slider.value_changed.connect(Callable(self, "_on_sfx_volume_changed"))
	
func _on_master_volume_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value))
	
func _on_music_volume_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(value))
	
func _on_sfx_volume_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(value))

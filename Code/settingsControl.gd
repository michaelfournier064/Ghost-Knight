extends Control

const ACTIONS := {
	"jump": KEY_SPACE,
	"sprint": KEY_SHIFT
}

func _ready() -> void:
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
	var master_slider = $VBoxContainer/MasterVolumeContainer/MasterVolumeSlider
	var music_slider  = $VBoxContainer/MusicVolumeContainer/MusicVolumeSlider
	var sfx_slider    = $VBoxContainer/SfxVolumeContainer/SfxVolumeSlider

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

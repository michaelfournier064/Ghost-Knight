extends Control

const SETTINGS_SCENE := preload("res://Scenes/Settings.tscn")
var _settings_ui: Control = null

@onready var horror_music: AudioStreamPlayer = $"Horror-background-music-302076"
@onready var click_sound:  AudioStreamPlayer     = $clickSound
@onready var play:         Button                = $MarginContainer/VBoxContainer/play
@onready var load_button:  Button                = $MarginContainer/VBoxContainer/load_button
@onready var settings_btn: Button                = $MarginContainer/VBoxContainer/settings
@onready var quit:         Button                = $MarginContainer/VBoxContainer/quit

func _ready() -> void:
	$MarginContainer/VBoxContainer/gameTitle.add_theme_font_size_override("font_size", 50)
	for btn in [play, load_button, settings_btn, quit]:
		btn.add_theme_font_size_override("font_size", 20)
		var empty = StyleBoxEmpty.new()
		for state in ["normal", "hover", "pressed", "focus"]:
			btn.add_theme_stylebox_override(state, empty)

func _on_play_pressed() -> void:
	click_sound.play()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/first_level.tscn")

func _on_settings_pressed() -> void:
	click_sound.play()
	if _settings_ui:
		return  # already opened
	_settings_ui = SETTINGS_SCENE.instantiate()
	_settings_ui.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	_settings_ui.connect("settings_closed", _on_settings_closed)
	get_tree().get_root().add_child(_settings_ui)
	get_tree().paused = true

func _on_quit_pressed() -> void:
	click_sound.play()
	get_tree().quit()

func _on_load_pressed() -> void:
	click_sound.play()
	# TODO: Implement load logic

func _on_button_mouse_entered() -> void:
	click_sound.play()

func _on_settings_closed() -> void:
	get_tree().paused = false
	_settings_ui = null

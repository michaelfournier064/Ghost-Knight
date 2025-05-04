# File: res://Code/titleScreen.gd
extends Control

const SETTINGS_SCENE := preload("res://Scenes/Settings.tscn")
const LEVEL_SCENE    := "res://Scenes/first_level.tscn"

var _settings_ui: Control = null

@onready var click_sound:  AudioStreamPlayer = $clickSound
@onready var play:         Button            = $MarginContainer/VBoxContainer/play
@onready var load_button:  Button            = $MarginContainer/VBoxContainer/load_button
@onready var settings_btn: Button            = $MarginContainer/VBoxContainer/settings
@onready var quit:         Button            = $MarginContainer/VBoxContainer/quit

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	# Style title & buttons
	$MarginContainer/VBoxContainer/gameTitle.add_theme_font_size_override("font_size", 50)
	for btn in [play, load_button, settings_btn, quit]:
		btn.add_theme_font_size_override("font_size", 20)

	# Connect signals only once, using Callable for both is_connected & connect
	var cb_play     = Callable(self, "_on_play_pressed")
	var cb_load     = Callable(self, "_on_load_pressed")
	var cb_settings = Callable(self, "_on_settings_pressed")
	var cb_quit     = Callable(self, "_on_quit_pressed")

	if not play.is_connected("pressed", cb_play):
		play.pressed.connect(cb_play)
	if not load_button.is_connected("pressed", cb_load):
		load_button.pressed.connect(cb_load)
	if not settings_btn.is_connected("pressed", cb_settings):
		settings_btn.pressed.connect(cb_settings)
	if not quit.is_connected("pressed", cb_quit):
		quit.pressed.connect(cb_quit)

func _on_play_pressed() -> void:
	click_sound.play()
	get_tree().paused = false
	get_tree().change_scene_to_file(LEVEL_SCENE)

func _on_load_pressed() -> void:
	click_sound.play()
	# TODO: implement load functionality

func _on_settings_pressed() -> void:
	click_sound.play()
	if _settings_ui:
		return  # already open
	_settings_ui = SETTINGS_SCENE.instantiate()
	_settings_ui.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	_settings_ui.connect("settings_closed", Callable(self, "_on_settings_closed"))
	get_tree().get_root().add_child(_settings_ui)
	get_tree().paused = true

func _on_quit_pressed() -> void:
	click_sound.play()
	get_tree().quit()

func _on_settings_closed() -> void:
	get_tree().paused = false
	_settings_ui.queue_free()
	_settings_ui = null

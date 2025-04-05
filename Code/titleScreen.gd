extends Control

@onready var background_music: AudioStreamPlayer = $BackgroundMusic
@onready var v_box_container: VBoxContainer = $MarginContainer/VBoxContainer
@onready var game_title: Label = $MarginContainer/VBoxContainer/gameTitle
@onready var play: Control = $MarginContainer/VBoxContainer/PlayButton
@onready var load_button: Control = $MarginContainer/VBoxContainer/LoadButton
@onready var settings: Control = $MarginContainer/VBoxContainer/SettingsButton
@onready var quit: Control = $MarginContainer/VBoxContainer/QuitButton
@onready var click_sound: AudioStreamPlayer = $clickSound

func _ready() -> void:
	# Adjust game title size.
	game_title.add_theme_font_size_override("font_size", 50)
	
	# Connect signals using Callables.
	play.connect("pressed", Callable(self, "_on_play_pressed"))
	load_button.connect("pressed", Callable(self, "_on_load_pressed"))
	settings.connect("pressed", Callable(self, "_on_settings_pressed"))
	quit.connect("pressed", Callable(self, "_on_quit_pressed"))
	
	# Optionally, connect mouse_entered signals for playing a click sound.
	play.connect("mouse_entered", Callable(self, "_on_button_mouse_entered"))
	load_button.connect("mouse_entered", Callable(self, "_on_button_mouse_entered"))
	settings.connect("mouse_entered", Callable(self, "_on_button_mouse_entered"))
	quit.connect("mouse_entered", Callable(self, "_on_button_mouse_entered"))

func _on_play_pressed() -> void:
	print("Play button pressed.")

func _on_load_pressed() -> void:
	print("Load button pressed.")

func _on_settings_pressed() -> void:
	print("Settings button pressed.")

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_button_mouse_entered() -> void:
	if click_sound.playing:
		click_sound.stop()
	click_sound.play()

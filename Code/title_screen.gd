extends Control

@onready var v_box_container: VBoxContainer = $MarginContainer/VBoxContainer
@onready var game_title: Label = $MarginContainer/VBoxContainer/gameTitle
@onready var play: Button = $MarginContainer/VBoxContainer/play
@onready var load: Button = $MarginContainer/VBoxContainer/load
@onready var settings: Button = $MarginContainer/VBoxContainer/settings
@onready var quit: Button = $MarginContainer/VBoxContainer/quit

func _ready() -> void:
	# Adjust game title size
	game_title.add_theme_font_size_override("font_size", 50)
	# Adjust button font sizes
	play.add_theme_font_size_override("font_size", 20)
	load.add_theme_font_size_override("font_size", 20)
	settings.add_theme_font_size_override("font_size", 20)
	quit.add_theme_font_size_override("font_size", 20)

	# Connect button signals
	play.pressed.connect(_on_play_pressed)
	load.pressed.connect(_on_load_pressed)
	settings.pressed.connect(_on_settings_pressed)
	quit.pressed.connect(_on_quit_pressed)

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/player.tscn")

func _on_load_pressed() -> void:
	print("Load button pressed.")

func _on_settings_pressed() -> void:
	print("Settings button pressed.")

func _on_quit_pressed() -> void:
	get_tree().quit()

extends Control

@onready var horror_background_music: AudioStreamPlayer = $"Horror-background-music-302076"
@onready var click_sound: AudioStreamPlayer = $clickSound
@onready var v_box_container: VBoxContainer = $MarginContainer/VBoxContainer
@onready var game_title: Label = $MarginContainer/VBoxContainer/gameTitle
@onready var play: Button = $MarginContainer/VBoxContainer/play
@onready var load_button: Button = $MarginContainer/VBoxContainer/load_button
@onready var settings: Button = $MarginContainer/VBoxContainer/settings
@onready var quit: Button = $MarginContainer/VBoxContainer/quit

func _ready() -> void:
	# Adjust game title size
	game_title.add_theme_font_size_override("font_size", 50)
	# Adjust button font sizes
	play.add_theme_font_size_override("font_size", 20)
	load_button.add_theme_font_size_override("font_size", 20)
	settings.add_theme_font_size_override("font_size", 20)
	quit.add_theme_font_size_override("font_size", 20)
	horror_background_music.play()
	
	# Remove button styles for a flat appearance
	var empty_style := StyleBoxEmpty.new()
	play.add_theme_stylebox_override("normal", empty_style)
	play.add_theme_stylebox_override("hover", empty_style)
	play.add_theme_stylebox_override("pressed", empty_style)
	play.add_theme_stylebox_override("focus", empty_style)

	load_button.add_theme_stylebox_override("normal", empty_style)
	load_button.add_theme_stylebox_override("hover", empty_style)
	load_button.add_theme_stylebox_override("pressed", empty_style)
	load_button.add_theme_stylebox_override("focus", empty_style)

	settings.add_theme_stylebox_override("normal", empty_style)
	settings.add_theme_stylebox_override("hover", empty_style)
	settings.add_theme_stylebox_override("pressed", empty_style)
	settings.add_theme_stylebox_override("focus", empty_style)

	quit.add_theme_stylebox_override("normal", empty_style)
	quit.add_theme_stylebox_override("hover", empty_style)
	quit.add_theme_stylebox_override("pressed", empty_style)
	quit.add_theme_stylebox_override("focus", empty_style)

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/first_level.tscn")
	print("Play button pressed.")

func _on_load_pressed() -> void:
	print("Load button pressed.")

func _on_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Settings.tscn")
	print("Settings button pressed.")

func _on_quit_pressed() -> void:
	get_tree().quit()
	print("Quit button pressed.")

func _on_button_mouse_entered() -> void:
	if click_sound.playing:
		click_sound.stop()
	click_sound.play()

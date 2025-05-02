# File: res://Code/settingsControl.gd
extends Control

@onready var returnMainMenu : Button            = $backGroundImage/ReturnSaveVBoxContainer/ReturnMainMenuButton
@onready var returnToGame   : Button            = $backGroundImage/ReturnSaveVBoxContainer/ReturnToGameButton
@onready var saveChanges    : Button            = $backGroundImage/ReturnSaveVBoxContainer/SaveChangesButton
@onready var click_sound    : AudioStreamPlayer = $backGroundImage/clickSound

@onready var master_slider  : HSlider           = $backGroundImage/MainVBox/AudioVBox/MasterVolumeContainer/MasterVolumeSlider
signal settings_closed

func _ready() -> void:
	SettingsLoaderSingleton.load_settings()
	# configure slider
	master_slider.min_value = 0.0
	master_slider.max_value = 1.0
	master_slider.step      = 0.01
	_sync_gui_to_current_settings()

	returnToGame.visible = get_tree().paused
	returnMainMenu.pressed.connect(_on_return_main_menu_button_pressed)
	returnToGame.pressed.connect(_on_return_to_game_button_pressed)
	saveChanges.pressed.connect(_on_save_changes_pressed)

func _sync_gui_to_current_settings() -> void:
	var db = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))
	master_slider.value = db_to_linear(db)

func _on_return_main_menu_button_pressed() -> void:
	click_sound.play()
	SettingsLoaderSingleton.save_settings()
	get_tree().paused = false
	emit_signal("settings_closed")
	get_tree().change_scene_to_file("res://Scenes/TitleScreen.tscn")

func _on_return_to_game_button_pressed() -> void:
	click_sound.play()
	SettingsLoaderSingleton.save_settings()
	get_tree().paused = false
	emit_signal("settings_closed")
	queue_free()

func _on_save_changes_pressed() -> void:
	click_sound.play()
	SettingsLoaderSingleton.save_settings()

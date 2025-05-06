extends Control

const SETTINGS_SCENE      := preload("res://Scenes/Settings.tscn")
const SAVE_MANAGER_TYPE   := preload("res://Code/SaveManager.gd")

@onready var new_game_btn = $MarginContainer/VBoxContainer/new_game
@onready var play_btn     = $MarginContainer/VBoxContainer/play
@onready var load_btn     = $MarginContainer/VBoxContainer/load_button
@onready var settings_btn = $MarginContainer/VBoxContainer/settings
@onready var quit_btn     = $MarginContainer/VBoxContainer/quit
@onready var click_sound  = $clickSound
var _settings_ui           : Node = null

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	# If there are no saves, hide Play & Load so the VBox reflows
	if SAVE_MANAGER_TYPE.get_save_list().is_empty():
		play_btn.visible = false
		load_btn.visible = false

	# Connect button signals if not already
	var cb_new      = Callable(self, "_on_new_game_pressed")
	var cb_play     = Callable(self, "_on_play_pressed")
	var cb_load     = Callable(self, "_on_load_pressed")
	var cb_settings = Callable(self, "_on_settings_pressed")
	var cb_quit     = Callable(self, "_on_quit_pressed")

	if not new_game_btn.is_connected("pressed", cb_new):
		new_game_btn.pressed.connect(cb_new)
	if not play_btn.is_connected("pressed", cb_play):
		play_btn.pressed.connect(cb_play)
	if not load_btn.is_connected("pressed", cb_load):
		load_btn.pressed.connect(cb_load)
	if not settings_btn.is_connected("pressed", cb_settings):
		settings_btn.pressed.connect(cb_settings)
	if not quit_btn.is_connected("pressed", cb_quit):
		quit_btn.pressed.connect(cb_quit)

func _on_new_game_pressed() -> void:
	click_sound.play()

	# 1) Reset the in-memory GameState to its true defaults:
	GameStateManager.reset_state()

	# 2) Save that fresh state out to disk:
	GameStateManagerSingleton.save_state()

	# 3) Now treat it like a normal save: bundle the level into the file
	var data = GameStateManager.state.duplicate(true)
	data.level = GameStateManager.target_level
	SaveManager.create_new_save(data)

	# 4) Finally, jump into the scene:
	var scene_path = LevelConfigManager.get_level_path(GameStateManager.target_level)
	get_tree().change_scene_to_file(scene_path)

func _on_play_pressed() -> void:
	click_sound.play()

	# get_most_recent_save is non-static, so call on the Autoload instance:
	var path = SaveManager.get_most_recent_save()

	# load_save is static, so call on the type:
	var data = SAVE_MANAGER_TYPE.load_save(path)
	if data.size() == 0:
		push_error("Failed to load save data.")
		return

	GameStateManager.state = data
	var lvl   = data.get("level", GameStateManager.target_level)
	var scene = LevelConfigManager.get_level_path(lvl)
	if scene != "":
		get_tree().change_scene_to_file(scene)
	else:
		push_error("Invalid level path for loaded save.")

func _on_load_pressed() -> void:
	click_sound.play()
	get_tree().change_scene_to_file("res://Scenes/LoadScreen.tscn")

func _on_settings_pressed() -> void:
	click_sound.play()
	if _settings_ui != null:
		return  # already open
	_settings_ui = SETTINGS_SCENE.instantiate()
	_settings_ui.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	_settings_ui.connect("settings_closed", Callable(self, "_on_settings_closed"))
	get_tree().get_root().add_child(_settings_ui)
	get_tree().paused = true

func _on_settings_closed() -> void:
	get_tree().paused = false
	if _settings_ui:
		_settings_ui.queue_free()
		_settings_ui = null

func _on_quit_pressed() -> void:
	click_sound.play()
	get_tree().quit()

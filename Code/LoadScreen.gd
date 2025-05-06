extends Control

# Preload the script *types* for all static calls
const SaveManagerType      = preload("res://Code/SaveManager.gd")
const GameStateManagerType = preload("res://Code/GameStateManager.gd")
const LevelConfigType      = preload("res://Code/LevelConfig.gd")

@onready var scroll_vbox   : VBoxContainer = $ScrollContainer/VBoxContainer
@onready var back_button   : Button         = $BackButton

func _ready() -> void:
	# Connect the Back button
	back_button.pressed.connect(self._on_back)
	# Populate the save list
	_populate()

func _populate() -> void:
	for child in scroll_vbox.get_children():
		child.queue_free()

	# Fetch saved files from the script type
	var saves: Array = SaveManagerType.get_save_list()
	for path in saves:
		var data: Dictionary = SaveManagerType.load_save(path)
		if data.is_empty():
			push_error("Selected save was empty or invalid: %s" % path)
			return

		var ts = FileAccess.get_modified_time(path)
		var dt = Time.get_datetime_dict_from_unix_time(ts)

		var lvl = data.get("level", "Unknown")
		var label_text = "%s — %04d-%02d-%02d %02d:%02d" % [
			lvl,
			dt.year, dt.month, dt.day,
			dt.hour, dt.minute
		]

		var btn = Button.new()
		btn.text = label_text
		btn.pressed.connect(Callable(self, "_on_select").bind(path))
		scroll_vbox.add_child(btn)

func _on_select(path: String) -> void:
	# Load save via the static type
	var data: Dictionary = SaveManagerType.load_save(path)

	# Restore in-memory state (instance)
	GameStateManager.state = data
	# Persist via static on script type
	GameStateManagerType.save_state()
	# Jump to saved level via static on script type
	GameStateManager.target_level = data.get("level", "Unknown")
	var scene_path: String = LevelConfigType.get_level_path(GameStateManager.target_level)
	if scene_path == "":
		push_error("Unknown level '%s' in save: %s" % [GameStateManager.target_level, path])
		return

	get_tree().change_scene_to_file(scene_path)

func _on_back() -> void:
	get_tree().change_scene_to_file("res://Scenes/TitleScreen.tscn")

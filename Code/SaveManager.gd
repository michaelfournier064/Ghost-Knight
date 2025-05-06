# SaveManager.gd
extends Node

# Directory under user:// where saves are stored
const SAVE_DIR := "saves/"
const EXT := ".save"

func _ready() -> void:
	# Ensure the save directory exists under the user data path
	var dir_root = DirAccess.open("user://")
	if dir_root and not dir_root.dir_exists(SAVE_DIR):
		dir_root.make_dir_recursive(SAVE_DIR)

func create_new_save(data: Dictionary) -> String:
	# Pull the level name out of the save data
	var level_name = data.get("level", "UnknownLevel")

	# Get the current Unix time and format a timestamp
	var unix_ts = int(Time.get_unix_time_from_system())
	var dt = Time.get_datetime_dict_from_unix_time(unix_ts)
	var ts_str = "%04d%02d%02d_%02d%02d%02d" % [
		dt.year, dt.month, dt.day,
		dt.hour, dt.minute, dt.second
	]

	# Build filename and full user:// path
	var filename = "%s_%s%s" % [level_name, ts_str, EXT]
	var full_path = "user://" + SAVE_DIR + filename

	# Write out the JSON
	_write(full_path, data)
	return full_path

func get_most_recent_save() -> String:
	var list = get_save_list()
	if list.size() > 0:
		return list[0]
	else:
		return ""

static func get_save_list() -> Array:
	var dir = DirAccess.open("user://saves")
	if not dir:
		return []
	var saves = []
	dir.list_dir_begin()
	var fname = dir.get_next()
	while fname != "":
		if not dir.current_is_dir() and fname.to_lower().ends_with(EXT):
			saves.append("user://saves/%s" % fname)
		fname = dir.get_next()
	dir.list_dir_end()
	# Filenames include a sortable timestamp, so lexicographic sort works:
	saves.sort()
	saves.reverse()  # newest first
	return saves

static func load_save(path: String) -> Dictionary:
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		return {}
	var text = file.get_as_text()
	file.close()

	var json = JSON.new()
	var err = json.parse(text)
	if err != OK:
		# parse() failed, return an empty dict
		return {}
	# json.data holds the parsed Variant (Dictionary, Array, etc.)
	if typeof(json.data) == TYPE_DICTIONARY:
		return json.data
	else:
		return {}

func _write(path: String, data: Dictionary) -> void:
	var f = FileAccess.open(path, FileAccess.WRITE)
	if not f:
		push_error("Cannot write save: %s" % path)
		return
	f.store_string(JSON.stringify(data))
	f.close()

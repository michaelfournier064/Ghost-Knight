extends Node
class_name LevelConfigManager

# Map a friendly name to its scene path.
static var LEVELS = {
	"Graveyard": "res://Scenes/first_level.tscn",
}

# Return all available level names.
static func get_names() -> Array:
	return LEVELS.keys()

# Return the scene path for a given friendly name.
static func get_level_path(friendly_name: String) -> String:
	if LEVELS.has(friendly_name):
		return LEVELS[friendly_name]
	else:
		return ""

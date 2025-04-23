extends Node
const CONFIG_FILE := "user://settings.cfg"

func _ready() -> void:
    var cfg := ConfigFile.new()
    if cfg.load(CONFIG_FILE) != OK:
        return                                 # first run – nothing to load

    if cfg.has_section("keys"):
        for action_name in cfg.get_section_keys("keys"):
            var code : int = cfg.get_value("keys", action_name)
            var ev  := InputEventKey.new()
            ev.physical_keycode = code
            InputMap.action_erase_events(action_name)
            InputMap.action_add_event(action_name, ev)

extends Node3D

const SETTINGS_SCENE := preload("res://Scenes/Settings.tscn")
var _settings_ui: Control = null

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey \
    and event.keycode == KEY_ESCAPE \
    and event.pressed and not event.echo:
        if _settings_ui:
            return
        var ui: Control = SETTINGS_SCENE.instantiate()
        ui.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
        get_tree().get_root().add_child(ui)
        get_tree().paused = true
        _settings_ui = ui

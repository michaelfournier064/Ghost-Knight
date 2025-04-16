extends Button

@export var action_name: String

func _ready() -> void:
	toggle_mode = true
	text = get_key_text()
	toggled.connect(Callable(self, "_on_toggled"))

func _on_toggled(pressed: bool) -> void:
	set_process_unhandled_input(pressed)
	if pressed:
		text = "... Press key ..."
		release_focus()
	else:
		text = get_key_text()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		InputMap.action_erase_events(action_name)
		InputMap.action_add_event(action_name, event)
		ProjectSettings.save()
		set_pressed(false)

func get_key_text() -> String:
	var events = InputMap.action_get_events(action_name)
	for ev in events:
		if ev is InputEventKey:
			return ev.as_text()
	return "None"

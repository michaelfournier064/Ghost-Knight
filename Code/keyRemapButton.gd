extends Button
@export var action_name: String = ""

var _waiting_for_key := false

func _ready() -> void:
	add_to_group("key_remap_button")
	_refresh_caption()
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	if _waiting_for_key:
		return
	_waiting_for_key = true
	text = "Press any key…"
	set_process_input(true)

func _input(event: InputEvent) -> void:
	if not _waiting_for_key:
		return

	var handled := false
	if event is InputEventKey and event.pressed and not event.is_echo():
		_apply_new_binding(event)
		handled = true
	elif event is InputEventMouseButton and event.pressed:
		_apply_new_binding(event)
		handled = true

	if handled:
		get_viewport().set_input_as_handled()

func _apply_new_binding(event: InputEvent) -> void:
	var evt := event.duplicate()
	if evt is InputEventKey:
		evt.echo = false   # only keys have `echo`

	InputMap.action_erase_events(action_name)
	InputMap.action_add_event(action_name, evt)

	_waiting_for_key = false
	set_process_input(false)
	_refresh_caption()

func _refresh_caption() -> void:
	var events := InputMap.action_get_events(action_name)
	if events.is_empty():
		text = "Bind"
		return

	var ev := events[0]
	if ev is InputEventKey:
		text = OS.get_keycode_string(ev.keycode)
	elif ev is InputEventMouseButton:
		text = "Mouse %d" % ev.button_index
	else:
		text = "Set…"

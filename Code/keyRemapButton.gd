extends Button
## The input‑action this button is responsible for
@export var action_name : String = ""

var _waiting_for_key := false     # true while we are listening

func _ready() -> void:
	_refresh_caption()
	pressed.connect(_on_pressed)

# ─────────────────────────────────────────────────────────────
# 1.  User clicks the button  → enter “listening mode”
# ─────────────────────────────────────────────────────────────
func _on_pressed() -> void:
	if _waiting_for_key:
		return
	_waiting_for_key = true
	text = "Press any key…"
	set_process_unhandled_input(true)   # Start listening for raw key events

# ─────────────────────────────────────────────────────────────
# 2.  First Key (or Mouse Button) the user hits  → remap
# ─────────────────────────────────────────────────────────────
func _unhandled_input(event : InputEvent) -> void:
	if not _waiting_for_key:
		return                         # Only react while we’re waiting
	if event is InputEventKey and event.pressed and not event.echo:
		_apply_new_binding(event)
	elif event is InputEventMouseButton and event.pressed:
		_apply_new_binding(event)

	#   prevent other UI from also consuming this first event
	if _waiting_for_key:
		accept_event()

# ─────────────────────────────────────────────────────────────
# 3.  Replace the action’s events, update caption, stop listening
# ─────────────────────────────────────────────────────────────
func _apply_new_binding(event : InputEvent) -> void:
	#  Make a clean copy so we don’t keep “echo” or “pressed” flags around
	var evt := event.duplicate()
	evt.echo = false
	evt.pressed = false

	#  Wipe old bindings and add the new one
	InputMap.action_erase_events(action_name)
	InputMap.action_add_event(action_name, evt)

	#  UI cleanup
	_waiting_for_key = false
	set_process_unhandled_input(false)
	_refresh_caption()

func _refresh_caption() -> void:
	# Show the *first* key bound to this action (empty → ask user)
	var events := InputMap.action_get_events(action_name)
	if events.size() == 0:
		text = "Bind"
		return
	var e := events[0]
	if e is InputEventKey:
		text = OS.get_keycode_string(e.keycode)
	elif e is InputEventMouseButton:
		text = "Mouse " + str(e.button_index)
	else:
		text = "Set…"

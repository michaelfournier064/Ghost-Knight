extends Button

func _ready() -> void:
	# Connect the pressed signal to our custom method.
	self.pressed.connect(_on_quit_button_pressed)

func _on_quit_button_pressed() -> void:
	get_tree().quit()

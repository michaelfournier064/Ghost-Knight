extends Control
@export var text: String = "Button"
@export var font: Font

signal custom_pressed

var label: Label

func _ready() -> void:
	print("CustomButton _ready() called")
	# Create and configure the label.
	label = Label.new()
	label.text = text
	if font:
		label.add_theme_font_override("font", font)
	else:
		var default_font = get_theme_font("font")
		if default_font:
			label.add_theme_font_override("font", default_font)
		else:
			print("Warning: No default theme font found.")
	add_child(label)
	
	# Compute the text size using the effective font.
	var effective_font = font if font != null else get_theme_font("font")
	if effective_font == null:
		push_error("No effective font available for CustomButton!")
		return
	var text_size: Vector2 = effective_font.get_string_size(text)
	
	# Set the label's size to match exactly the size the text takes up.
	label.rect_min_size = text_size
	label.rect_size = text_size
	
	# Center the label inside this control by setting anchors and pivot_offset.
	label.anchor_left = 0.5
	label.anchor_top = 0.5
	label.anchor_right = 0.5
	label.anchor_bottom = 0.5
	label.pivot_offset = text_size / 2.0
	
	# Set this control's minimum size to match the label's text size.
	self.custom_minimum_size = text_size

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var local_mouse: Vector2 = get_local_mouse_position()
		# Use the label's own position and size to determine the clickable area.
		var clickable_rect: Rect2 = Rect2(label.rect_position, label.rect_size)
		if clickable_rect.has_point(local_mouse):
			emit_signal("custom_pressed")
			event.accept()

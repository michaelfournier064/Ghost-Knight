extends CharacterBody3D

@export var speed = 5.0
@export var jump_velocity = 4.5
@onready var head = $Head
@onready var camera = $Head/Camera3D

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var health := 100

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	print("Player ready, health:", health)

func _physics_process(delta):
	var direction = Vector3(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		0,
		Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
	).normalized()

	var cam_xform = camera.global_transform.basis
	direction = (cam_xform.x * direction.x + cam_xform.z * direction.z).normalized()

	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		if Input.is_action_just_pressed("jump"):
			velocity.y = jump_velocity

	velocity.x = direction.x * speed
	velocity.z = direction.z * speed

	move_and_slide()

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * 0.1))
		head.rotate_x(deg_to_rad(-event.relative.y * 0.1))
		head.rotation_degrees.x = clamp(head.rotation_degrees.x, -90, 90)

# -----------------------------------
# Damage Handling Methods
# -----------------------------------

func take_damage(amount: int) -> void:
	health -= amount
	print("Player takes damage: %d, health left: %d" % [amount, health])
	if health <= 0:
		die()

func die() -> void:
	print("Player died!")
	get_tree().call_group("game", "on_player_death")

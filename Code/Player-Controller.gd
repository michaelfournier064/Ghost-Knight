# ProtoController v1.0 by Brackeys
# CC0 License
# Intended for rapid prototyping of first-person games.
# Happy prototyping!

extends CharacterBody3D
class_name Player

@export var Health := 3

@export_group("WhatCanYouDO")
## Can we move around?
@export var can_move : bool = true
## Are we affected by gravity?
@export var has_gravity : bool = true
## Can we press to jump?
@export var can_jump : bool = true
## Can we hold to run?
@export var can_sprint : bool = true
## Can we Dash
@export var can_dash : bool = true
## Can we Dash
@export var can_attack : bool = true
#####################################################################################################################
@export_group("Speeds")
## Look around rotation speed.
@export var look_speed : float = 0.002
## Normal speed.
@export var base_speed : float = 7.0
## Speed of jump.
@export var jump_velocity : float = 4.5
## How fast do we run?
@export var sprint_speed : float = 10.0
#####################################################################################################################
@export_group("Input Actions")
## Name of Input Action to move Left.
@export var input_left : String = "Left"
## Name of Input Action to move Right.
@export var input_right : String = "Right"
## Name of Input Action to move Forward.
@export var input_forward : String = "Forward"
## Name of Input Action to move Backward.
@export var input_back : String = "Back"
## Name of Input Action to Jump.
@export var input_jump : String = "Jump"
## Name of Input Action to Sprint.
@export var input_sprint : String = "Sprint"
## name of Input Action to Dash
@export var input_dash : String = "Dash"
## blah
@export var input_attack : String = "Attack"

var mouse_captured : bool = false
var look_rotation : Vector2
var move_speed : float = 0.0
var attack_cooldown := 0.5

## IMPORTANT REFERENCES
@onready var head: Node3D = $Head
@onready var collider: CollisionShape3D = $Collider
@onready var Animate: AnimationPlayer = $"Placeholder art/AnimationPlayer"
@onready var attack_timer: Timer = $"Attack Timer"
@onready var attack_box: Area3D = $AttackBox

func _ready() -> void:
	check_input_mappings()
	look_rotation.y = rotation.y
	look_rotation.x = head.rotation.x
	attack_box.monitoring = false
	attack_box.monitorable = false

func _unhandled_input(event: InputEvent) -> void:
	# Mouse capturing
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		capture_mouse()
	if Input.is_key_pressed(KEY_ESCAPE):
		release_mouse()
	
	# Look around
	if mouse_captured and event is InputEventMouseMotion:
		rotate_look(event.relative)
	

func _physics_process(delta: float) -> void:
	# attack input
	if Input.is_action_just_pressed("Attack") and can_attack:
		Animate.play("1H_Melee_Attack_Stab")
		preform_attack()
	
	
	# Apply gravity to velocity
	if has_gravity:
		if not is_on_floor():
			velocity += get_gravity() * delta

	# Apply jumping
	if can_jump:
		if Input.is_action_just_pressed(input_jump) and is_on_floor():
			Animate.play("Jump_Start")
			velocity.y = jump_velocity
			
	# Modify speed based on sprinting
	if can_sprint and is_on_floor() and Input.is_action_pressed(input_sprint):
		move_speed = sprint_speed
	else:
		move_speed = base_speed

	# Apply desired movement to velocity
	if can_move:
		var input_dir := Input.get_vector(input_left, input_right, input_forward, input_back)
		var move_dir := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if move_dir == Vector3.ZERO:
			Animate.play("Idle_Combat")
		if !move_dir == Vector3.ZERO:
			Animate.play("Walking_D_Skeletons")
		if move_dir:
			velocity.x = move_dir.x * move_speed
			velocity.z = move_dir.z * move_speed
		else:
			velocity.x = move_toward(velocity.x, 0, move_speed)
			velocity.z = move_toward(velocity.z, 0, move_speed)
	else:
		velocity.x = 0
		velocity.y = 0
	
	if can_dash and Input.is_action_pressed("Dash"):
		velocity += Vector3.FORWARD
		
	# Use velocity to actually move
	move_and_slide()


## Rotate us to look around.
## Base of controller rotates around y (left/right). Head rotates around x (up/down).
## Modifies look_rotation based on rot_input, then resets basis and rotates by look_rotation.
func rotate_look(rot_input : Vector2):
	look_rotation.x -= rot_input.y * look_speed
	look_rotation.x = clamp(look_rotation.x, deg_to_rad(-85), deg_to_rad(85))
	look_rotation.y -= rot_input.x * look_speed
	transform.basis = Basis()
	rotate_y(look_rotation.y)
	head.transform.basis = Basis()
	head.rotate_x(look_rotation.x)




func capture_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true

func release_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = false

func preform_attack():
	can_attack = false
	attack_box.monitoring = true
	await get_tree().create_timer(0.2).timeout
	attack_box.monitoring = false
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true

func Take_Damage(Dmg):
	Health -= Dmg
	print(Health)
	if Health <= 0:
		print("Death")

func _on_attack_box_body_entered(body: Node3D) -> void:
	if body.has_method("death"):
		body.death()

## Checks if some Input Actions haven't been created.
## Disables functionality accordingly.
func check_input_mappings():
	if can_move and not InputMap.has_action(input_left):
		push_error("Movement disabled. No InputAction found for input_left: " + input_left)
		can_move = false
	if can_move and not InputMap.has_action(input_right):
		push_error("Movement disabled. No InputAction found for input_right: " + input_right)
		can_move = false
	if can_move and not InputMap.has_action(input_forward):
		push_error("Movement disabled. No InputAction found for input_forward: " + input_forward)
		can_move = false
	if can_move and not InputMap.has_action(input_back):
		push_error("Movement disabled. No InputAction found for input_back: " + input_back)
		can_move = false
	if can_jump and not InputMap.has_action(input_jump):
		push_error("Jumping disabled. No InputAction found for input_jump: " + input_jump)
		can_jump = false
	if can_sprint and not InputMap.has_action(input_sprint):
		push_error("Sprinting disabled. No InputAction found for input_sprint: " + input_sprint)
		can_sprint = false

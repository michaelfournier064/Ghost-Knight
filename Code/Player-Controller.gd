# File: res://Code/Player-Controller.gd
extends CharacterBody3D
class_name Player

@export_group("Health")
@export var max_health : int
var Health : int

@export var regen_interval : float
var regen_timer : float = 0.0

@export_group("WhatCanYouDO")
@export var can_move   : bool = true
@export var has_gravity: bool = true
@export var can_jump   : bool = true
@export var can_sprint : bool = true
@export var can_dash   : bool = true
@export var can_attack : bool = true

@export_group("Speeds")
@export var look_speed    : float = 0.002
@export var base_speed    : float
@export var sprint_speed  : float
@export var jump_velocity : float
@export var dash_strength : float
@export var attack_cooldown: float

@export_group("Input Actions")
@export var input_left   : String
@export var input_right  : String
@export var input_forward: String
@export var input_back   : String
@export var input_jump   : String
@export var input_sprint : String
@export var input_dash   : String
@export var input_attack : String

var mouse_captured : bool = false
var look_rotation : Vector2
var move_speed    : float = 0.0

@onready var head       = $Head
@onready var collider   = $Collider
@onready var model      = $Skeleton_Rogue
@onready var animate    = model.get_node("AnimationPlayer")
@onready var attack_box = $AttackBox

func _ready() -> void:
	# Load defaults from singleton
	var pd = GameStateManagerSingleton.state.player_defaults
	max_health       = pd.max_health
	regen_interval   = pd.regen_interval
	base_speed       = pd.base_speed
	sprint_speed     = pd.sprint_speed
	jump_velocity    = pd.jump_velocity
	dash_strength    = pd.dash_strength
	attack_cooldown  = pd.attack_cooldown

	input_left       = pd.input_left
	input_right      = pd.input_right
	input_forward    = pd.input_forward
	input_back       = pd.input_back
	input_jump       = pd.input_jump
	input_sprint     = pd.input_sprint
	input_dash       = pd.input_dash
	input_attack     = pd.input_attack

	# Load persisted state
	var sp = GameStateManagerSingleton.state
	global_transform.origin = GameStateManagerSingleton._dict_to_vec3(sp.player_pos)
	Health = sp.player_health if sp.player_health != null else max_health

	get_tree().connect("tree_exiting", Callable(self, "_on_quit"))

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		capture_mouse()
	if Input.is_key_pressed(KEY_ESCAPE):
		release_mouse()
	if mouse_captured and event is InputEventMouseMotion:
		rotate_look(event.relative)

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed(input_attack) and can_attack:
		perform_attack()

	if has_gravity and not is_on_floor():
		velocity += get_gravity() * delta

	if can_jump and Input.is_action_just_pressed(input_jump) and is_on_floor():
		animate.play("Jump_Start")
		velocity.y = jump_velocity

	# Movement speed
	move_speed = sprint_speed if is_on_floor() and Input.is_action_pressed(input_sprint) and can_sprint else base_speed

	var in_dir = Input.get_vector(input_left, input_right, input_forward, input_back)
	var move_dir = (transform.basis * Vector3(in_dir.x, 0, in_dir.y)).normalized()

	if move_dir == Vector3.ZERO:
		animate.play("Idle_Combat")
		velocity.x = move_toward(velocity.x, 0, move_speed * delta * 8)
		velocity.z = move_toward(velocity.z, 0, move_speed * delta * 8)
	else:
		animate.play("Walking_D_Skeletons")
		velocity.x = move_dir.x * move_speed
		velocity.z = move_dir.z * move_speed

	if can_dash and Input.is_action_just_pressed(input_dash):
		velocity += transform.basis.z.normalized() * dash_strength

	move_and_slide()

	regen_timer += delta
	if regen_timer >= regen_interval:
		regen_timer -= regen_interval
		Health = min(Health + 1, max_health)
		print("Player regenerated 1 HP. Current HP:", Health)

func rotate_look(rot_input : Vector2) -> void:
	look_rotation.x = clamp(look_rotation.x - rot_input.y * look_speed, deg_to_rad(-85), deg_to_rad(85))
	look_rotation.y -= rot_input.x * look_speed
	transform.basis = Basis()
	rotate_y(look_rotation.y)
	head.transform.basis = Basis()
	head.rotate_x(look_rotation.x)

func capture_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true

func release_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = false

func perform_attack() -> void:
	can_attack = false
	animate.play("1H_Melee_Attack_Stab")
	attack_box.monitoring = true
	await get_tree().create_timer(0.5).timeout
	attack_box.monitoring = false
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true

func Take_Damage(dmg: int) -> void:
	Health -= dmg
	print("Player HP:", Health)
	if Health <= 0:
		GameStateManager.reset_state()
		get_tree().change_scene_to_file("res://Scenes/LoseScreen.tscn")

func _on_attack_box_body_entered(body: Node) -> void:
	if body.has_method("Take_Damage"):
		body.Take_Damage(1)

func _on_quit() -> void:
	GameStateManagerSingleton.state.player_pos    = GameStateManagerSingleton._vec3_to_dict(global_transform.origin)
	GameStateManagerSingleton.state.player_health = Health
	GameStateManagerSingleton.save_state()

extends CharacterBody3D
class_name Player

@export_group("Health")
@export var max_health : int = 10
var Health : int = max_health
@export var regen_interval : float = 30.0  # seconds between each +1 HP
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
@export var base_speed    : float = 7.0
@export var jump_velocity : float = 4.5
@export var sprint_speed  : float = 10.0
@export var dash_strength : float = 15.0
@export var attack_cooldown: float = 1.0

@export_group("Input Actions")
@export var input_left   : String = "Left"
@export var input_right  : String = "Right"
@export var input_forward: String = "Forward"
@export var input_back   : String = "Back"
@export var input_jump   : String = "Jump"
@export var input_sprint : String = "Sprint"
@export var input_dash   : String = "Dash"
@export var input_attack : String = "Attack"

var mouse_captured : bool = false
var look_rotation : Vector2
var move_speed    : float = 0.0

@onready var head       = $Head
@onready var collider   = $Collider
@onready var Animate    = $"Placeholder art/AnimationPlayer"
@onready var attack_box = $AttackBox

func _ready() -> void:
    add_to_group("Player")
    look_rotation = Vector2(rotation.y, head.rotation.x)
    # Ensure the box can detect bodies:
    print("Enabling hit-box")
    attack_box.monitoring = true
    attack_box.monitoring = false
    attack_box.connect("body_entered", Callable(self, "_on_attack_box_body_entered"))
    check_input_mappings()

func _unhandled_input(event: InputEvent) -> void:
    if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
        capture_mouse()
    if Input.is_key_pressed(KEY_ESCAPE):
        release_mouse()
    if mouse_captured and event is InputEventMouseMotion:
        rotate_look(event.relative)

func _physics_process(delta: float) -> void:
    # --- Attack handling ---
    if Input.is_action_just_pressed(input_attack) and can_attack:
        Animate.play("1H_Melee_Attack_Stab")
        preform_attack()

    # --- Gravity & Jump ---
    if has_gravity and not is_on_floor():
        velocity += get_gravity() * delta

    if can_jump and Input.is_action_just_pressed(input_jump) and is_on_floor():
        Animate.play("Jump_Start")
        velocity.y = jump_velocity

    # --- Movement ---
    move_speed = sprint_speed if can_sprint and is_on_floor() and Input.is_action_pressed(input_sprint) else base_speed
    var in_dir = Input.get_vector(input_left, input_right, input_forward, input_back)
    var move_dir = (transform.basis * Vector3(in_dir.x, 0, in_dir.y)).normalized()

    if move_dir == Vector3.ZERO:
        Animate.play("Idle_Combat")
        velocity.x = move_toward(velocity.x, 0, move_speed * delta * 8)
        velocity.z = move_toward(velocity.z, 0, move_speed * delta * 8)
    else:
        Animate.play("Walking_D_Skeletons")
        velocity.x = move_dir.x * move_speed
        velocity.z = move_dir.z * move_speed

    if can_dash and Input.is_action_just_pressed(input_dash):
        var fwd = transform.basis.z.normalized()
        velocity += fwd * dash_strength

    move_and_slide()

    # --- Health Regeneration ---
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

func preform_attack() -> void:
    can_attack = false
    attack_box.monitoring = true
    await get_tree().create_timer(0.2).timeout
    attack_box.monitoring = false
    await get_tree().create_timer(attack_cooldown).timeout
    can_attack = true

func Take_Damage(dmg: int) -> void:
    Health -= dmg
    print("Player HP:", Health)
    if Health <= 0:
        # on death, go to Lose screen
        get_tree().change_scene_to_file("res://Scenes/LoseScreen.tscn")

func _on_attack_box_body_entered(body: Node) -> void:
    if body.has_method("Take_Damage"):
        body.Take_Damage(1)

func check_input_mappings() -> void:
    for action in [input_left, input_right, input_forward, input_back]:
        if can_move and not InputMap.has_action(action):
            push_error("Missing input action: %s" % action)
            can_move = false

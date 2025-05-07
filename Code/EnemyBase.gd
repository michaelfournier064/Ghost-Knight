# res://Code/EnemyBase.gd
extends CharacterBody3D
class_name EnemyBase

enum State { CHASE, ATTACK }

@export var speed           : float
@export var attack_range    : float
@export var attack_cooldown : float
@export var max_health      : int

var health     : int
var can_attack : bool = true
var state      : State = State.CHASE
var target     : Node3D

@onready var animation_player = $Skeleton_Minion/AnimationPlayer
@onready var attack_box        = $AttackBox

func _ready() -> void:
	add_to_group("enemies")
	# Initialize from GameStateManager defaults
	var ed = GameStateManagerSingleton.state.enemy_defaults
	# Assign all tunable stats
	speed           = ed.speed
	attack_range    = ed.attack_range
	attack_cooldown = ed.attack_cooldown
	max_health      = ed.max_health
	health          = max_health

	# Setup hitbox signal
	attack_box.monitoring = false
	var hit_cb = Callable(self, "_on_attack_box_body_entered")
	if not attack_box.is_connected("body_entered", hit_cb):
		attack_box.connect("body_entered", hit_cb)

func _physics_process(delta: float) -> void:
	# Apply gravity if needed
	if not is_on_floor():
		velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity") * delta

	# Lazy-load player target
	if not target:
		var players = get_tree().get_nodes_in_group("Player")
		if players.size() > 0:
			target = players[0]
		else:
			return

	# Compute flat vector to player
	var to_player = target.global_transform.origin - global_transform.origin
	to_player.y = 0

	# State machine transitions
	if state == State.CHASE:
		if to_player.length() <= attack_range:
			state = State.ATTACK
		else:
			_chase_player(to_player)
	elif state == State.ATTACK:
		if can_attack:
			_perform_attack()
		if to_player.length() > attack_range:
			state = State.CHASE

	move_and_slide()

func _chase_player(direction: Vector3) -> void:
	look_at(target.global_transform.origin, Vector3.UP)
	direction = direction.normalized()
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed
	animation_player.play("Walking_D_Skeletons")

func _perform_attack() -> void:
	can_attack = false
	# Default melee behavior
	attack_box.monitoring = true
	animation_player.play("1H_Melee_Attack_Stab")
	# Allow damage overlap window
	await get_tree().create_timer(0.15).timeout
	attack_box.monitoring = false
	# Cooldown
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true

func _on_attack_box_body_entered(body: Node) -> void:
	if body.has_method("Take_Damage"):
		body.Take_Damage(1)

func Take_Damage(dmg: int) -> void:
	health -= dmg
	if health <= 0:
		queue_free()

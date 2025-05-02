# File: res://Code/RogueSkeletonEnemy.gd
extends CharacterBody3D
class_name RogueSkeletonEnemy

enum State { CHASE, ATTACK }

@export var target_path: NodePath
var target: Node3D

# Runtime properties (initialized in _ready)
var speed: float
var attack_cooldown: float
var attack_range: float
var health: int
var can_attack := true
var state = State.CHASE

@onready var model      = $Model
@onready var animate    = model.get_node("AnimationPlayer")
@onready var attack_box = $AttackBox

func _ready() -> void:
	# Make this enemy findable via group
	add_to_group("enemies")

	# Load defaults
	var ed = GameStateManager.state.enemy_defaults
	speed            = ed.speed
	attack_cooldown  = ed.attack_cooldown
	attack_range     = ed.attack_range
	health           = ed.max_health

	_hide_hood_and_cape()

	# Attack‐hitbox hookup
	attack_box.monitoring = false
	attack_box.connect("body_entered", Callable(self, "_on_attack_box_body_entered"))

func _physics_process(delta: float) -> void:
	# if gravity applies
	if not is_on_floor():
		velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity") * delta

	# lazy‐load the target if we don’t have one yet
	if not target:
		if target_path:
			target = get_node_or_null(target_path)
		if not target:
			var players = get_tree().get_nodes_in_group("Player")
			if players.size() > 0:
				target = players[0]
		# still no target? skip the rest this frame
		if not target:
			return

	# decide whether to chase or attack
	var to_player = target.global_transform.origin - global_transform.origin
	to_player.y = 0

	match state:
		State.CHASE:
			if to_player.length() <= attack_range:
				state = State.ATTACK
			else:
				_chase_player(to_player)
		State.ATTACK:
			if can_attack:
				_perform_attack()
			if to_player.length() > attack_range:
				state = State.CHASE

	move_and_slide()

func _chase_player(dir: Vector3) -> void:
	look_at(target.global_transform.origin, Vector3.UP)
	dir = dir.normalized()
	velocity.x = dir.x * speed
	velocity.z = dir.z * speed
	animate.play("Walking_D_Skeletons")

func _perform_attack() -> void:
	can_attack = false
	animate.play("1H_Melee_Attack_Stab")
	attack_box.monitoring = true
	await get_tree().create_timer(0.5).timeout
	attack_box.monitoring = false
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true

func _on_attack_box_body_entered(body: Node) -> void:
	if body.has_method("Take_Damage"):
		body.Take_Damage(1)

func Take_Damage(dmg: int) -> void:
	health -= dmg
	if health <= 0:
		queue_free()

func _hide_hood_and_cape() -> void:
	var rig = model.get_node_or_null("Rig/Skeleton3D")
	if rig:
		for part_name in ["Skeleton_Rogue_Hood", "Skeleton_Rogue_Cape"]:
			var part = rig.get_node_or_null(part_name)
			if part:
				part.hide()

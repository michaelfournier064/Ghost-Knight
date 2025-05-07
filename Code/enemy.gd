extends CharacterBody3D
class_name RogueSkeletonEnemy

enum State { CHASE, ATTACK,}

@export var target_path: NodePath
var target: Node3D

# Runtime properties (initialized in _ready)
var speed: float
var attack_cooldown: float
var attack_range: float
var health: int
var can_attack := true
var state = State.CHASE

@onready var model      = $Skeleton_Minion
@onready var animate    = model.get_node("AnimationPlayer")
@onready var attack_box = $AttackBox

func _ready() -> void:
	print("--ENEMY _ready()-- target_path:", target_path)
	# Make this enemy findable via group
	add_to_group("enemies")

	# Load defaults
	var ed = GameStateManager.state.enemy_defaults
	speed            = ed.speed
	attack_cooldown  = ed.attack_cooldown
	attack_range     = ed.attack_range
	health           = ed.max_health
	print("--Loaded defaults-- speed:", speed, " attack_range:", attack_range, " health:", health)

	_hide_hood_and_cape()

	# Attack-hitbox hookup (only connect once)
	attack_box.monitoring = false
	var hit_callable = Callable(self, "_on_attack_box_body_entered")
	print("--Connecting hitbox signal--")
	if not attack_box.is_connected("body_entered", hit_callable):
		attack_box.connect("body_entered", hit_callable)

func _physics_process(delta: float) -> void:
	print("--ENEMY _physics_process-- delta:", delta, " state:", state, " can_attack:", can_attack)
	# if gravity applies
	if not is_on_floor():
		velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity") * delta

	# lazy-load the target if we don’t have one yet
	if not target:
		if target_path:
			target = get_node_or_null(target_path)
		if not target:
			var players = get_tree().get_nodes_in_group("Player")
			if players.size() > 0:
				target = players[0]
		print("--Target after group lookup--", target)
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
	print("--ENEMY _chase_player-- dir:", dir)
	look_at(target.global_transform.origin, Vector3.UP)
	dir = dir.normalized()
	velocity.x = dir.x * speed
	velocity.z = dir.z * speed
	animate.play("Walking_D_Skeletons")

func _perform_attack() -> void:
	print("--ENEMY _perform_attack() start")
	can_attack = false
	animate.play("1H_Melee_Attack_Stab")
	# activate hitbox
	attack_box.monitoring = true
	print("--Attack box monitoring ON--")
	# allow some overlap time
	await get_tree().create_timer(0.15).timeout
	attack_box.monitoring = false
	print("--Attack box monitoring OFF--")
	# cooldown
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true
	print("--ENEMY _perform_attack() end, can_attack reset--")

func _on_attack_box_body_entered(body: Node) -> void:
	print("--ENEMY _on_attack_box_body_entered()-- body:", body.name)
	if body.has_method("Take_Damage"):
		body.Take_Damage(1)

func Take_Damage(dmg: int) -> void:
	print("--ENEMY Take_Damage()-- dmg:", dmg, " health_before:", health)
	health -= dmg
	print("--ENEMY Take_Damage()-- health_after:", health)
	if health <= 0:
		print("--ENEMY died--")
		queue_free()

func _hide_hood_and_cape() -> void:
	print("--ENEMY _hide_hood_and_cape()-- hiding parts")
	var rig = model.get_node_or_null("Rig/Skeleton3D")
	if rig:
		for part_name in ["Skeleton_Rogue_Hood", "Skeleton_Rogue_Cape"]:
			var part = rig.get_node_or_null(part_name)
			if part:
				print("--Hiding part--", part_name)
				part.hide()

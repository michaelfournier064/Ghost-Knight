extends CharacterBody3D
class_name RogueSkeletonEnemy

@export var target_path: NodePath
@export var speed: float = 4.0
@export var max_health := 2
@export var attack_cooldown := 1.0

@onready var model       = $Model
@onready var animate     = $Model/AnimationPlayer
@onready var collider    = $Collider
@onready var attack_box  = $AttackBox

var target: Node3D
var health := max_health
var can_attack := true

func _ready() -> void:
	_hide_hood_and_cape()
	target = get_node_or_null(target_path)
	attack_box.monitoring = false

func _hide_hood_and_cape() -> void:
	var rig = model.get_node_or_null("Rig/Skeleton3D")
	if rig:
		var hood = rig.get_node_or_null("Skeleton_Rogue_Hood")
		if hood:
			hood.hide()
		else:
			print("Hood not found")
		
		var cape = rig.get_node_or_null("Skeleton_Rogue_Cape")
		if cape:
			cape.hide()
		else:
			print("Cape not found")
	else:
		print("Rig not found")

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity") * delta

	if target:
		var dir = target.global_position - global_position
		dir.y = 0
		if dir.length() > 1.5:
			look_at(target.global_position, Vector3.UP)
			dir = dir.normalized()
			velocity.x = dir.x * speed
			velocity.z = dir.z * speed
			animate.play("Walking_D_Skeletons")
		else:
			if can_attack:
				animate.play("1H_Melee_Attack_Stab")
				attack()
			velocity.x = 0
			velocity.z = 0
			animate.play("Idle_Combat")

	move_and_slide()

func attack() -> void:
	can_attack = false
	attack_box.monitoring = true
	await get_tree().create_timer(0.2).timeout
	attack_box.monitoring = false
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true

func _on_attack_box_body_entered(body: Node) -> void:
	if body.has_method("Take_Damage"):
		body.Take_Damage(1)

func Take_Damage(dmg: int) -> void:
	health -= dmg
	print("Enemy HP:", health)
	if health <= 0:
		die()

func die() -> void:
	queue_free()

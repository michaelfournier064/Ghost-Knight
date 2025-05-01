extends CharacterBody3D
class_name RogueSkeletonEnemy

@export var target_path: NodePath
@export var speed: float = 4.0

@onready var model       = $Model
@onready var animate     = $Model/AnimationPlayer
@onready var collider    = $Collider
@onready var attack_box  = $AttackBox

var target: Node3D

func _ready() -> void:
	_hide_hood_and_cape()
	target = get_node_or_null(target_path)

func _hide_hood_and_cape() -> void:
	var rig = model.get_node_or_null("Rig/Skeleton3D")
	if rig:
		var hood = rig.get_node_or_null("Skeleton_Rogue_Hood")
		var cape = rig.get_node_or_null("Skeleton_Rogue_Cape")
		if hood:
			hood.hide()
		else:
			print("Hood not found")
		if cape:
			cape.hide()
		else:
			print("Cape not found")

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity") * delta

	if target:
		var dir = target.global_position - global_position
		dir.y = 0
		if dir.length() > 0.1:
			look_at(target.global_position, Vector3.UP)
			dir = dir.normalized()
			velocity.x = dir.x * speed
			velocity.z = dir.z * speed
			animate.play("Walking_D_Skeletons")
		else:
			animate.play("Idle_Combat")

	move_and_slide()

func die() -> void:
	queue_free()

func _on_attack_box_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		animate.play("1H_Melee_Attack_Stab")
		die()

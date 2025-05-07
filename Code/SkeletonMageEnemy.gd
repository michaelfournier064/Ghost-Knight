# res://Code/SkeletonMageEnemy.gd
extends EnemyBase
class_name SkeletonMageEnemy

@export var detection_radius    : float
@export var projectile_scene: PackedScene


func _ready() -> void:
	# Initialize base melee defaults
	_ready()
	# Override with ranged defaults
	var rd = GameStateManagerSingleton.state.ranged_defaults
	detection_radius = rd.detection_radius
	attack_range     = detection_radius
	attack_cooldown  = rd.attack_cooldown
	max_health       = rd.max_health
	health           = max_health
	projectile_scene = load(rd.projectile_scene_path)

func _perform_attack() -> void:
	can_attack = false
	animation_player.play("Cast_Spell")
	# Spawn a projectile toward the target
	var dir = (target.global_transform.origin - global_transform.origin).normalized()
	var proj = projectile_scene.instantiate()
	proj.position = global_transform.origin
	proj.direction = dir
	get_parent().add_child(proj)
	# Cooldown
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true

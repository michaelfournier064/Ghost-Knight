extends CharacterBody3D
class_name RogueSkeletonEnemy

enum State { CHASE, ATTACK }

@export var target_path: NodePath
@export var speed := 4.0
@export var attack_cooldown := 1.0
@export var attack_range := 1.5

@onready var model      = $Model
@onready var animate    = model.get_node("AnimationPlayer")
@onready var attack_box = $AttackBox

var target: Node3D
var can_attack := true
var state = State.CHASE

func _ready():
    _hide_hood_and_cape()
    target = get_node_or_null(target_path)
    attack_box.monitoring = false
    attack_box.connect("body_entered", Callable(self, "_on_attack_box_body_entered"))

func _physics_process(delta):
    if not is_on_floor():
        velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity") * delta
    if not target:
        return

    var to_player = target.global_position - global_position
    to_player.y = 0

    match state:
        State.CHASE:
            if to_player.length() <= attack_range:
                state = State.ATTACK
            else:
                chase_player(to_player, delta)
        State.ATTACK:
            if can_attack:
                perform_attack()
            if to_player.length() > attack_range:
                state = State.CHASE

    move_and_slide()

func chase_player(dir: Vector3, delta):
    look_at(target.global_position, Vector3.UP)
    dir = dir.normalized()
    velocity.x = dir.x * speed
    velocity.z = dir.z * speed
    animate.play("Walking_D_Skeletons")

func perform_attack():
    can_attack = false
    animate.play("1H_Melee_Attack_Stab")
    attack_box.monitoring = true
    await get_tree().create_timer(0.2).timeout
    attack_box.monitoring = false
    await get_tree().create_timer(attack_cooldown).timeout
    can_attack = true

func _on_attack_box_body_entered(body):
    if body.has_method("Take_Damage"):
        body.Take_Damage(1)

# Restores the skeleton's hood and cape visibility when instantiating
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

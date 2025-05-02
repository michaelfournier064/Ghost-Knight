extends CharacterBody3D
class_name RogueSkeletonEnemy

enum State { CHASE, ATTACK }

@export var target_path: NodePath
@export var speed := 4.0
@export var attack_cooldown := 1.0
@export var attack_range := 1.5
@export var max_health := 2

@onready var model      = $Model
@onready var animate    = model.get_node("AnimationPlayer")
@onready var attack_box = $AttackBox

var target: Node3D
var health := max_health
var can_attack := true
var state = State.CHASE

func _ready() -> void:
    _hide_hood_and_cape()
    target = get_node_or_null(target_path)
    attack_box.monitoring = false
    attack_box.connect("body_entered", Callable(self, "_on_attack_box_body_entered"))

func _physics_process(delta: float) -> void:
    if not is_on_floor():
        velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity") * delta
    if target == null:
        return

    var to_player = target.global_position - global_position
    to_player.y = 0

    match state:
        State.CHASE:
            if to_player.length() <= attack_range:
                state = State.ATTACK
            else:
                chase_player(to_player)
        State.ATTACK:
            if can_attack:
                perform_attack()
            if to_player.length() > attack_range:
                state = State.CHASE

    move_and_slide()

func chase_player(dir: Vector3) -> void:
    look_at(target.global_position, Vector3.UP)
    dir = dir.normalized()
    velocity.x = dir.x * speed
    velocity.z = dir.z * speed
    animate.play("Walking_D_Skeletons")

func perform_attack() -> void:
    can_attack = false
    animate.play("1H_Melee_Attack_Stab")
    attack_box.monitoring = true
    print("Enemy attack box ON")
    await get_tree().create_timer(0.5).timeout   # extended window to 0.5s for debug
    attack_box.monitoring = false
    print("Enemy attack box OFF")
    await get_tree().create_timer(attack_cooldown).timeout
    can_attack = true

func _on_attack_box_body_entered(body: Node) -> void:
    if body.has_method("Take_Damage"):
        body.Take_Damage(1)

func Take_Damage(dmg: int) -> void:
    health -= dmg
    print("Skeleton hit! HP now:", health)
    if health <= 0:
        print("Skeleton dying")
        queue_free()

func _hide_hood_and_cape() -> void:
    var rig = model.get_node_or_null("Rig/Skeleton3D")
    if rig:
        for name in ["Skeleton_Rogue_Hood", "Skeleton_Rogue_Cape"]:
            var part = rig.get_node_or_null(name)
            if part:
                part.hide()
            else:
                print(name, "not found")
    else:
        print("Rig not found")

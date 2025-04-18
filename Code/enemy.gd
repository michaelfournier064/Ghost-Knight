extends CharacterBody3D

var damage := 10
var attack_range := 2.0
var attack_cooldown := 1.5
var time_since_attack := 0.0
var player: Node3D = null

func _ready() -> void:
    player = get_tree().get_root().get_node("Main/Player")

func _physics_process(delta: float) -> void:
    if not player:
        return

    var to_player = player.global_transform.origin - global_transform.origin
    if to_player.length() > attack_range:
        velocity = to_player.normalized() * 2.0
    else:
        velocity = Vector3.ZERO
        time_since_attack += delta
        if time_since_attack >= attack_cooldown:
            attack()
            time_since_attack = 0.0

    move_and_slide()

func attack() -> void:
    if player.has_method("take_damage"):
        player.take_damage(damage)
        print("Enemy attacks player for", damage)

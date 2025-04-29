extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@export var Damage := 1

@onready var Target : Player

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	Follow_Player()
	move_and_slide()

func Follow_Player():
	if !Target: 
		return
	var direction = Target.global_position - global_position
	var NewSpeed = direction.normalized() * SPEED
	velocity = NewSpeed

func _on_player_detection_body_entered(body: Node3D) -> void:
	if body is Player:
		Target = body

func death():
	queue_free()


func _on_damage_box_body_entered(body: Node3D) -> void:
	if body.has_method("Take_Damage"):
		body.Take_Damage(Damage)

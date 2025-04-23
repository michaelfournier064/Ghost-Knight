extends CharacterBody3D

class_name Enemy

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var Target : Player

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	move_and_slide()

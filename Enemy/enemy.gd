extends CharacterBody3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer


const SPEED = 3.0
const JUMP_VELOCITY = 4.5

var is_idling : bool = true
var is_following : bool = false
var is_attacking : bool = false

@export var Damage := 1

@onready var Target : Player


func _ready() -> void:
	is_idling = true

func _physics_process(delta: float):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	Follow_Player()
	move_and_slide()
	enemy_animations()



func Follow_Player():
	if is_following == true:
		if !Target: 
			return
		var direction = Target.global_position - global_position
		var NewSpeed = direction.normalized() * SPEED
		velocity = NewSpeed
		self.look_at(Target.global_transform.origin,Vector3.UP)
		self.rotate_y(PI)
	else:
		is_idling = true
		velocity = Vector3.ZERO


func _on_player_detection_body_entered(body: Node3D):
	if body is Player:
		is_following = true
		is_idling = false
		Target = body

func _on_player_detection_body_exited(body: Node3D):
	if body is Player:
		is_following = false
		

func death():
	queue_free()


func _on_damage_box_body_entered(body: Node3D):
	if body.has_method("Take_Damage"):
		body.Take_Damage(Damage)

func enemy_animations():
	if is_idling == true:
		animation_player.play("Idle")

	if is_following == true:
		animation_player.play("Running_A")

	if is_attacking == true:
		animation_player.play("1H_Melee_Attack_Chop")

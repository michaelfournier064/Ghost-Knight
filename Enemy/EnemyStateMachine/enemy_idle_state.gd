extends NodeState

@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"



func on_process(_delta : float):
	pass

func on_physics_process(_delta : float):
	animation_player.play("Idle")

func enter():
	pass

func exit():
	pass

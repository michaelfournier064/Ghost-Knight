extends Node
class_name StateMachineController

@export var node_finite_state_machine : NodeFiniteStateMachine

func on_process(_delta : float):
	pass

func on_physics_process(_delta : float):
	pass

func enter():
	pass

func exit():
	pass


func _on_player_detection_body_entered(body: Node3D):
	node_finite_state_machine.transition_to("follow")

func _on_player_detection_body_exited(body: Node3D):
	node_finite_state_machine.transition_to("idle")

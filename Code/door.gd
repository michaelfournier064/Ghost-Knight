# door.gd
extends Area3D

@export var door_node_path: NodePath
@export var open_animation: String = "open"

var _has_opened := false

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if _has_opened:
		return
	if body.name == "Player":
		var door_node = get_node_or_null(door_node_path)
		if door_node and door_node.has_node("AnimationPlayer"):
			var anim_player = door_node.get_node("AnimationPlayer")
			anim_player.play(open_animation)
			_has_opened = true

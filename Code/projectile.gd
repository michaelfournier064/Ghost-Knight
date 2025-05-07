extends Area3D

@export var speed: float = 12.0
var direction: Vector3 = Vector3.ZERO

func _physics_process(delta: float) -> void:
	# Move in whatever direction was set
	translate(direction * speed * delta)

func _ready() -> void:
	# Auto-destruct after 5 seconds if it never hits anything
	await get_tree().create_timer(5.0).timeout
	queue_free()

func _on_body_entered(body: Node) -> void:
	if body.has_method("Take_Damage"):
		body.Take_Damage(1)
	queue_free()

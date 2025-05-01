# flicker_light.gd
extends OmniLight3D

@export var base_energy: float = 2.0
@export var flicker_range: float = 0.3
@export var flicker_speed: float = 0.05

func _ready():
	light_energy = base_energy
	_start_flicker()

func _start_flicker():
	await get_tree().create_timer(flicker_speed).timeout
	var random_offset = randf_range(-flicker_range, flicker_range)
	light_energy = clamp(base_energy + random_offset, 0.0, 8.0)
	_start_flicker()

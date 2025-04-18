extends Node
# Manages enemy waves and timing

var current_wave: int = 0
var wave_active: bool = false
var spawn_points: Array[Node3D] = []  # will hold enemy spawn point nodes

func _ready() -> void:
    # Gather enemy spawn point markers from the scene
    spawn_points = [ $"../EnemySpawn1", $"../EnemySpawn2" ]
    # Start the first wave
    start_next_wave()

func start_next_wave() -> void:
    if wave_active:
        return
    current_wave += 1
    wave_active = true
    print("Starting wave %d" % current_wave)
    # Example: spawn an enemy at the beginning of the wave
    spawn_enemy()
    # Wait for 10 seconds (placeholder for wave duration or enemy clearance)
    await get_tree().create_timer(10.0).timeout
    end_wave()

func spawn_enemy() -> void:
    if spawn_points.size() == 0:
        return
    var spawn = spawn_points[randi() % spawn_points.size()]
    # In a real game, instance an Enemy scene and add it at spawn.global_transform.origin
    print("Spawning enemy at ", spawn.name)

func end_wave() -> void:
    wave_active = false
    print("Wave %d ended" % current_wave % current_wave)
    # Placeholder: could trigger next wave or notify GameManager about wave completion

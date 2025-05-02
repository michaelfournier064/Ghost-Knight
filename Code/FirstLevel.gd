# File: res://Code/FirstLevel.gd
extends Node3D

const SETTINGS_SCENE    = preload("res://Scenes/Settings.tscn")
const ENEMY_SCENE       = preload("res://Scenes/Enemy.tscn")
@onready var player: Player = $Player

@export var spawn_area: AABB               = AABB(Vector3(-20, 0.5, -20), Vector3(40, 0, 40))
@export var initial_spawn_interval: float  = 5.0
@export var final_spawn_interval: float    = 1.0
@export var initial_speed_factor: float    = 0.75
@export var final_speed_factor: float      = 0.90

var _spawn_timer: Timer
var _win_timer: Timer
var _log_timer: Timer
var elapsed_time: float = 0.0  # in seconds

func _ready() -> void:
    _assign_enemy_targets()

    # Spawn timer
    _spawn_timer = Timer.new()
    _spawn_timer.one_shot = false
    _spawn_timer.timeout.connect(_spawn_enemy_randomly)
    add_child(_spawn_timer)
    _spawn_timer.wait_time = initial_spawn_interval
    _spawn_timer.start()

    # Win timer (7 minutes)
    _win_timer = Timer.new()
    _win_timer.one_shot = true
    _win_timer.wait_time = 7 * 60.0
    _win_timer.timeout.connect(_on_win_timer_timeout)
    add_child(_win_timer)
    _win_timer.start()

    # Log timer (every 5 seconds)
    _log_timer = Timer.new()
    _log_timer.one_shot = false
    _log_timer.wait_time = 5.0
    _log_timer.timeout.connect(_on_log_timer_timeout)
    add_child(_log_timer)
    _log_timer.start()

func _process(delta: float) -> void:
    elapsed_time += delta

func _assign_enemy_targets() -> void:
    for child in get_children():
        if child is Node and child.has_method("set_target_path"):
            child.set_target_path(player.get_path())

func _spawn_enemy(at_position: Vector3) -> void:
    var e = ENEMY_SCENE.instantiate()
    e.global_transform.origin = at_position
    if e is RogueSkeletonEnemy:
        var ratio = min(elapsed_time / (6 * 60.0), 1.0)
        var walk_speed = player.base_speed
        var run_speed  = player.sprint_speed
        var target_speed = lerp(initial_speed_factor * walk_speed,
                                final_speed_factor * run_speed,
                                ratio)
        e.speed = target_speed
        e.target_path = player.get_path()
    add_child(e)

func _spawn_enemy_randomly() -> void:
    # Update spawn interval dynamically
    var ratio = min(elapsed_time / (6 * 60.0), 1.0)
    _spawn_timer.wait_time = lerp(initial_spawn_interval,
                                  final_spawn_interval,
                                  ratio)
    # Random position
    var rx = randf_range(spawn_area.position.x,
                         spawn_area.position.x + spawn_area.size.x)
    var rz = randf_range(spawn_area.position.z,
                         spawn_area.position.z + spawn_area.size.z)
    var pos = Vector3(rx, spawn_area.position.y, rz)
    _spawn_enemy(pos)

func _on_win_timer_timeout() -> void:
    get_tree().change_scene_to_file("res://Scenes/WinScreen.tscn")

func _on_log_timer_timeout() -> void:
    var ratio = min(elapsed_time / (6 * 60.0), 1.0)
    var current_spawn = lerp(initial_spawn_interval,
                             final_spawn_interval,
                             ratio)
    var walk_speed   = player.base_speed
    var run_speed    = player.sprint_speed
    var current_speed = lerp(initial_speed_factor * walk_speed,
                             final_speed_factor * run_speed,
                             ratio)
    print("⏱ Time:", elapsed_time, 
          "– Spawn Interval:", current_spawn, 
          "s, Enemy Speed:", current_speed)

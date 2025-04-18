# res://Code/GameManager.gd
extends Node

var player_health: int = 100
var game_over:    bool = false

@onready var player          = get_node("../Player")
@onready var player_spawn    = get_node("../PlayerSpawn")
@onready var enemy           = get_node("../EnemyInstance1")
@onready var enemy_spawn     = get_node("../EnemySpawn1")
@onready var settings_button = get_node("../UILayer/SettingsButton")

func _ready() -> void:
	player.global_transform    = player_spawn.global_transform
	enemy.global_transform     = enemy_spawn.global_transform
	settings_button.connect("pressed", Callable(self, "_on_settings_pressed"))

func _on_settings_pressed() -> void:
	get_tree().change_scene("res://Scenes/Settings.tscn")

func on_player_death() -> void:
	game_over = true
	print("GAME OVER")
	get_tree().paused = true

func reduce_player_health(amount: int) -> void:
	if game_over:
		return
	player_health -= amount
	print("Player health: %d" % player_health)
	if player_health <= 0:
		on_player_death()

func restart_game() -> void:
	game_over = false
	player_health = 100
	print("Game Restarted")
	# reset wave manager state…

func _on_back_pressed() -> void:
	get_tree().change_scene("res://Scenes/TitleScreen.tscn")

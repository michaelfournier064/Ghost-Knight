# File: res://Scenes/LoseScreen.gd
extends Control

func _ready() -> void:
	$Card/VBox/ButtonContainer/QuitButton.connect("pressed", Callable(self, "_on_quit_pressed"))
	$Card/VBox/ButtonContainer/MenuButton.connect("pressed", Callable(self, "_on_menu_pressed"))

func _on_quit_pressed() -> void:
	GameStateManager.reset_state()
	get_tree().quit()

func _on_menu_pressed() -> void:
	GameStateManager.reset_state()
	get_tree().change_scene_to_file("res://Scenes/TitleScreen.tscn")

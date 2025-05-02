extends Control

func _ready() -> void:
    $Card/VBox/ButtonContainer/QuitButton.connect("pressed", Callable(self, "_on_quit_pressed"))
    $Card/VBox/ButtonContainer/MenuButton.connect("pressed", Callable(self, "_on_menu_pressed"))

func _on_quit_pressed() -> void:
    # Assumes you have a quitGame.gd somewhere that does `get_tree().quit()`
    var quit = preload("res://Code/quitGame.gd").new()
    quit._on_QuitGame_pressed()

func _on_menu_pressed() -> void:
    get_tree().change_scene_to_file("res://Scenes/titleScreen.tscn")

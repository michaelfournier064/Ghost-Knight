extends Node

# Optional functions for control
func play_music():
	$MenuBackgroundMusic.play()

func stop_music():
	$MenuBackgroundMusic.stop()

func set_volume(volume_db: float) -> void:
	$MenuBackgroundMusic.volume_db = volume_db

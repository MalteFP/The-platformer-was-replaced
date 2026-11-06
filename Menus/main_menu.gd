extends Control
var paused = false

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://Menus/select_level.tscn")


func _on_exit_pressed() -> void:
	get_tree().quit()

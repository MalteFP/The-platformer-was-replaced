extends Control

func _ready() -> void:
	get_node("CanvasLayer").hide()



func _on_next_level_pressed() -> void:
	ScreenHolder.currentScreenNum += 1
	ScreenHolder.currentScreenName = "levels/Level_" + str(ScreenHolder.currentScreenNum) + ".tscn"
	$CanvasLayer.hide()
	get_tree().get_first_node_in_group("GameInterpreter")._load_level(true) 


func _on_main_menu_pressed() -> void:
	$CanvasLayer.hide()
	get_tree().change_scene_to_file("res://Menus/main_menu.tscn")

	


func _on_retry_pressed() -> void:
	$CanvasLayer.hide()
	get_tree().get_first_node_in_group("GameInterpreter")._load_level(true) 

extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_next_level_pressed() -> void:
	ScreenHolder.currentScreenNum += 1
	ScreenHolder.currentScreenName = "levels/Level_" + str(ScreenHolder.currentScreenNum) + ".tscn"
	$CenterContainer.hide()
	get_tree().get_first_node_in_group("GameInterpreter")._load_level(true) 


func _on_main_menu_pressed() -> void:
	$CenterContainer.hide()
	get_tree().change_scene_to_file("res://Menus/main_menu.tscn")

	


func _on_retry_pressed() -> void:
	$CenterContainer.hide()
	get_tree().get_first_node_in_group("GameInterpreter")._load_level(true) 

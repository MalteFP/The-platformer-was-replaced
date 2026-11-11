extends Node2D
var carry_velocity := Vector2.ZERO


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		body.moving = 0
		$Base.play("Unlock")
		


func _on_base_animation_finished() -> void:
	get_tree().get_first_node_in_group("LevelComplete").get_node("CanvasLayer/CenterContainer/PanelContainer/VBoxContainer2/VBoxContainer/LevelComplete").text = "Level " + str(ScreenHolder.currentScreenNum + 1) + " Complete!"
	get_tree().get_first_node_in_group("LevelComplete").get_node("CanvasLayer").show()
	
	

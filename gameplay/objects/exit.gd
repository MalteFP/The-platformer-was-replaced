extends Node2D
var carry_velocity := Vector2.ZERO
var done: bool = false

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player" and not done:
		done = true
		body.moving = 0
		$Base.play("Unlock")
		get_tree().get_first_node_in_group("LevelComplete").get_node("CanvasLayer/CenterContainer/PanelContainer/VBoxContainer2/VBoxContainer/LevelComplete").text = "Level " + str(ScreenHolder.currentScreenNum + 1) + " Complete!"
		get_tree().get_first_node_in_group("LevelComplete").get_node("CanvasLayer").show()
		get_tree().get_first_node_in_group("GameInterpreter").get_node("CanvasLayer/VSplitContainer/HSplitContainer/VSplitContainer/HSplitContainer/Timer").isTicking = false
		get_tree().get_first_node_in_group("LevelComplete").get_node("CanvasLayer/CenterContainer/PanelContainer/VBoxContainer2/VBoxContainer/Timer").text = get_tree().get_first_node_in_group("GameInterpreter").get_node("CanvasLayer/VSplitContainer/HSplitContainer/VSplitContainer/HSplitContainer/Timer").text

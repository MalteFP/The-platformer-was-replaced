extends Node2D
var carry_velocity := Vector2.ZERO


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		ScreenHolder.currentScreenNum += 1
		ScreenHolder.currentScreenName = "levels/Level_" + str(ScreenHolder.currentScreenNum) + ".tscn"
		ScreenHolder.code_Saver = $"../../../Player/GameInterpreter/CanvasLayer/VSplitContainer/HSplitContainer/VSplitContainer/CodeEditor".text
		get_tree().change_scene_to_file(ScreenHolder.currentScreenName)

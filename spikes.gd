extends Node2D



func _on_area_2d_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body.name == "Player":
		ScreenHolder.code_Saver = $"../../../Player/GameInterpreter/CanvasLayer/VSplitContainer/HSplitContainer/VSplitContainer/CodeEditor".text
		get_tree().change_scene_to_file(ScreenHolder.currentScreenName)

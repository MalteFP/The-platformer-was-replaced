extends Node2D



func _on_area_2d_body_shape_entered(_body_rid: RID, body: Node2D, _body_shape_index: int, _local_shape_index: int) -> void:
	if body.name == "Player":
		ScreenHolder.code_Saver = $"../../../Player/GameInterpreter/CanvasLayer/VSplitContainer/HSplitContainer/VSplitContainer/CodeEditor".text
		get_tree().call_deferred("change_scene_to_file", ScreenHolder.currentScreenName)

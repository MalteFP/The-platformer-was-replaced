extends Node2D
var carry_velocity := Vector2.ZERO


<<<<<<< HEAD:gameplay/objects/exit.gd
func _on_area_2d_body_shape_entered(_body_rid: RID, body: Node2D, _body_shape_index: int, _local_shape_index: int) -> void:
	if body.name == "player":
=======
func _on_area_2d_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body.name == "Player":
>>>>>>> 82f0222043012ecf9bcc63e5bf6ee0403fedce48:exit.gd
		ScreenHolder.currentScreenNum += 1
		ScreenHolder.currentScreenName = "Level_" + str(ScreenHolder.currentScreenNum) + ".tscn"
		ScreenHolder.code_Saver = $"../../../Player/GameInterpreter/CanvasLayer/VSplitContainer/HSplitContainer/VSplitContainer/CodeEditor".text
		get_tree().change_scene_to_file(ScreenHolder.currentScreenName) # Replace with function body.

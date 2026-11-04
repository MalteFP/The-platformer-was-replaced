extends Node2D
var carry_velocity := Vector2.ZERO


func _on_area_2d_body_shape_entered(_body_rid: RID, body: Node2D, _body_shape_index: int, _local_shape_index: int) -> void:
	if body.name == "player":
		ScreenHolder.currentScreenNum += 1
		ScreenHolder.currentScreenName = "screens/level_" + str(ScreenHolder.currentScreenNum) + ".tscn"
		get_tree().change_scene_to_file(ScreenHolder.currentScreenName)
		

extends Node2D



func _on_area_2d_body_shape_entered(_body_rid: RID, body: Node2D, _body_shape_index: int, _local_shape_index: int) -> void:
	if body.name == "Player":
		body.death()
		await get_tree().create_timer(0.59).timeout
		get_tree().get_first_node_in_group("GameInterpreter")._load_level()

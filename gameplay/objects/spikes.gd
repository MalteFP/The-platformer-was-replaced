extends Node2D



func _on_area_2d_body_shape_entered(_body_rid: RID, body: Node2D, _body_shape_index: int, _local_shape_index: int) -> void:
	if body.name == "Player" and not body.dead:
		body.death()
		var tree = get_tree()
		await body.sprite.animation_finished
		tree.get_first_node_in_group("GameInterpreter")._load_level()

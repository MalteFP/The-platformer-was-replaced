extends Node2D
var carry_velocity := Vector2.ZERO


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		body.moving = 0
		$Base.play("Unlock")
		


func _on_base_animation_finished() -> void:
	await get_tree().create_timer(0.5).timeout
	ScreenHolder.currentScreenNum += 1
	ScreenHolder.currentScreenName = "levels/Level_" + str(ScreenHolder.currentScreenNum) + ".tscn"
	ScreenHolder.code_Saver = $"../../../Player/GameInterpreter/CanvasLayer/VSplitContainer/HSplitContainer/VSplitContainer/CodeEditor".text
	get_tree().call_deferred("change_scene_to_file", ScreenHolder.currentScreenName)

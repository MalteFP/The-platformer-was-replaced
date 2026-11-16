
extends Control

func _ready() -> void:
	custom_minimum_size = Vector2(150, 150)

	var i = 0

	while ResourceLoader.exists("res://levels/Level_" + str(i) + ".tscn"):
		var scene = load("res://Menus/select_level_level.tscn")

		if scene == null:
			push_error("Could not load level button scene!")
			break

		var instance = scene.instantiate()

		instance.setup(i)

		get_node("FlowContainer").add_child(instance)

		i += 1

	var btn = Button.new()
	btn.text = "Back"
	btn.pressed.connect(goToMainMenu)

	get_node("FlowContainer").add_child(btn)


func goToMainMenu():
	get_tree().change_scene_to_file("res://Menus/main_menu.tscn")

extends Control

func _ready() -> void:
	custom_minimum_size = Vector2(150,150)
	var imgFound = true
	var i = 0
	while imgFound:
		if FileAccess.file_exists("res://levels/Level_" + str(i) + ".tscn"):
			var l = load("res://Menus/select_level_level.tscn")
			
			var instance = l.instantiate()
			instance.setup(i, "res://levels/level_img/level_pic_" + str(i) + ".png")

			get_node("FlowContainer").add_child(instance)
			i += 1
		else:
			imgFound = false
	var btn = Button.new()
	btn.pressed.connect(func(): goToMainMenu())
	btn.text = "Back"
	get_node("FlowContainer").add_child(btn)
	




func goToMainMenu():
	get_tree().change_scene_to_file("res://Menus/main_menu.tscn")

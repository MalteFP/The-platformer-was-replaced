
extends Control
@onready var c = $CenterContainer/VSplitContainer/FlowContainer

signal levels_loaded

func _ready() -> void:
	loading_screen(levels_loaded)
	Save.load_level_completions(ScreenHolder.LEVEL_AMOUNT)
	var completions = await Save.level_completions_loaded
	custom_minimum_size = Vector2(150, 150)

	var i = 0

	while ResourceLoader.exists("res://levels/Level_" + str(i) + ".tscn"):
		var scene = load("res://Menus/select_level_level.tscn")

		if scene == null:
			push_error("Could not load level button scene!")
			break

		var instance = scene.instantiate()
		if i == 0:
			instance.setup(i, true)
		else:
			instance.setup(i, completions[i] or completions[i - 1])

		c.add_child(instance)

		i += 1

	var btn = Button.new()
	btn.text = "Back"
	btn.pressed.connect(goToMainMenu)

	c.get_parent().add_child(btn)
	emit_signal("levels_loaded")


func goToMainMenu():
	await close_loading_screen()
	get_tree().change_scene_to_file("res://Menus/main_menu.tscn")



func close_loading_screen():
	var top: Sprite2D = $"Loading screen/top"
	var bottom: Sprite2D = $"Loading screen/bottom"
	
	var tween_down = create_tween()
	tween_down.parallel().tween_property(top, "position", Vector2(0, 0), 0.5)
	tween_down.parallel().tween_property(bottom, "position", Vector2(0, 0), 0.5)
	await tween_down.finished

func loading_screen(s = null):
	var top: Sprite2D = $"Loading screen/top"
	var bottom: Sprite2D = $"Loading screen/bottom"
	
	var tween_down = create_tween()
	tween_down.parallel().tween_property(top, "position", Vector2(0, 0), 0.5)
	tween_down.parallel().tween_property(bottom, "position", Vector2(0, 0), 0.5)
	if s:
		await s
	
	var tween_up = create_tween()
	tween_up.parallel().tween_property(top, "position", Vector2(0, -360), 0.5)
	tween_up.parallel().tween_property(bottom, "position", Vector2(0, 324), 0.5)

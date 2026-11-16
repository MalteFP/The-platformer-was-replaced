
extends Button

var levelNum: int = 0

func setup(levelNumber: int) -> void:
	levelNum = levelNumber
	text = "Level: " + str(levelNum + 1)

func _ready() -> void:
	var style = StyleBoxFlat.new()
	style.set_border_width_all(2)
	style.bg_color = Color(0.255, 0.255, 0.255, 0.447)

	add_theme_stylebox_override("normal", style)
	add_theme_stylebox_override("hover", style)
	add_theme_stylebox_override("pressed", style)

	pressed.connect(func(): loadLevel(levelNum))


func loadLevel(lvl: int) -> void:
	ScreenHolder.currentScreenNum = lvl
	ScreenHolder.currentScreenName = "res://levels/Level_" + str(lvl) + ".tscn"
	get_tree().change_scene_to_file("res://Code Editor/UI.tscn")

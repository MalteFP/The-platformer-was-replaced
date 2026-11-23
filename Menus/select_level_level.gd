
extends Button

var levelNum: int = 0
var enabled: bool

func setup(levelNumber: int, e: bool) -> void:
	levelNum = levelNumber
	text = str(levelNum + 1)
	enabled = e

func _ready() -> void:
	var style = StyleBoxFlat.new()
	style.set_border_width_all(2)
	style.bg_color = Color(0.255, 0.255, 0.255, 0.447)

	add_theme_stylebox_override("normal", style)
	add_theme_stylebox_override("hover", style)
	add_theme_stylebox_override("pressed", style)
	disabled = !enabled
	pressed.connect(func(): loadLevel(levelNum))


func loadLevel(lvl: int) -> void:
	await get_tree().get_first_node_in_group("select level").close_loading_screen()
	ScreenHolder.currentScreenNum = lvl
	ScreenHolder.currentScreenName = "res://levels/Level_" + str(lvl) + ".tscn"
	get_tree().change_scene_to_file("res://Code Editor/UI.tscn")

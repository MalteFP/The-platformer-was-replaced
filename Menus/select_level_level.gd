extends Button

var levelNum
var picture


func _ready() -> void:
	var style = StyleBoxFlat.new()
	style.set_border_width_all(2)
	style.bg_color = Color(0.255, 0.255, 0.255, 0.447)
	self.add_theme_stylebox_override("normal", style)
	self.add_theme_stylebox_override("hover", style)
	self.add_theme_stylebox_override("pressed", style)
	
	self.text = "Level: " + str(levelNum)
	self.pressed.connect(func(): loadLevel(levelNum))

func setup(levelNumber, picturePath):
	levelNum = levelNumber
	picture = picturePath

func loadLevel(lvl):
	ScreenHolder.currentScreenNum = lvl
	ScreenHolder.currentScreenName = "res://levels/Level_" + str(lvl) + ".tscn"
	get_tree().change_scene_to_file("levels/Level_" + str(lvl) + ".tscn")

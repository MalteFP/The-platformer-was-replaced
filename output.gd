extends CodeEdit



func _ready() -> void:
	draw_control_chars = false
	syntax_highlighter = create_custom_highligther()
	add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0))


func create_custom_highligther() -> CodeHighlighter:
	var highlighter = CodeHighlighter.new()

	highlighter.add_color_region("Error", "", Color.FIREBRICK, true)
	highlighter.add_color_region("OUTPUT:", " ", Color.FIREBRICK, true)
	return highlighter

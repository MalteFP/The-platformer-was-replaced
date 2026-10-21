extends TextEdit

var keywords: Array[Dictionary] = [
	{"keyword": "while","color": Color.ORANGE},
	{"keyword": "for","color": Color.ORANGE},
	{"keyword": "if","color": Color.ORANGE}
	]

func _ready() -> void:
	draw_control_chars = false
	syntax_highlighter = create_custom_highligther()
	add_theme_color_override("font_color", Color(0.545, 0.692, 0.999, 1.0))


func create_custom_highligther() -> CodeHighlighter:
	var highlighter = CodeHighlighter.new()
	for keyword in keywords:
		highlighter.add_keyword_color(keyword["keyword"], keyword["color"])
	highlighter.add_color_region('"', '"', Color.DARK_GREEN)
	highlighter.add_color_region("#", "", Color.DARK_GRAY, true)
	highlighter.number_color = Color.DARK_SEA_GREEN
	highlighter.function_color = Color.PURPLE
	highlighter.symbol_color = Color.WHITE
	return highlighter

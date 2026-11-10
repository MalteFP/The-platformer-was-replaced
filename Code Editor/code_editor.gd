extends CodeEdit
func _ready() -> void:
	draw_control_chars = false
	syntax_highlighter = create_custom_highlighter()
	add_theme_color_override("font_color", CodeColors.TEXT)
	set_auto_indent_prefixes(["{"])


func create_custom_highlighter() -> CodeHighlighter:
	var highlighter := CodeHighlighter.new()
	for kw in CodeColors.KEYWORDS:
		highlighter.add_keyword_color(kw, CodeColors.KEYWORDS[kw])
	highlighter.add_color_region('"', '"', CodeColors.STRING)
	highlighter.add_color_region("#", "", CodeColors.COMMENT, true)
	highlighter.number_color = CodeColors.NUMBER
	highlighter.function_color = CodeColors.FUNCTION
	highlighter.symbol_color = CodeColors.SYMBOL
	return highlighter

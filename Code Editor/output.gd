extends CodeEdit

func _ready() -> void:
	draw_control_chars = false
	editable = false
	highlight_current_line = false
	gutters_draw_line_numbers = false
	syntax_highlighter = OutputHighlighter.new()
	add_theme_color_override("font_color", Color.WHITE)
	add_theme_color_override("font_readonly_color", Color.WHITE)

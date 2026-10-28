class_name OutputHighlighter
extends SyntaxHighlighter

const TEXT_COLOR = Color.WHITE
const PREFIX_COLOR = Color(0.55, 0.55, 0.6)
const NUMBER_COLOR = Color(0.6, 0.85, 1.0)
const ERROR_LABEL_COLOR = Color(1.0, 0.35, 0.35)
const ERROR_TEXT_COLOR = Color(1.0, 0.65, 0.65)

var number_regex := RegEx.new()
var error_regex := RegEx.new()

func _init() -> void:
	number_regex.compile("(?<![\\w.])-?\\d+(\\.\\d+)?(?![\\w.])")
	error_regex.compile("^Error on line \\d+:")

func _get_line_syntax_highlighting(line: int) -> Dictionary:
	var text = get_text_edit().get_line(line)
	var result := {}

	if text.begins_with("OUTPUT:"):
		var start = "OUTPUT:".length()
		result[0] = {"color": PREFIX_COLOR}
		result[start] = {"color": TEXT_COLOR}
		for m in number_regex.search_all(text, start):
			result[m.get_start()] = {"color": NUMBER_COLOR}
			result[m.get_end()] = {"color": TEXT_COLOR}

	else:
		var m = error_regex.search(text)
		if m:
			result[0] = {"color": ERROR_LABEL_COLOR}
			result[m.get_end()] = {"color": ERROR_TEXT_COLOR}

	return result

class_name OutputLog
extends RichTextLabel

# Change these to restyle everything in one place
const C_TEXT := "#d8dee9"     # normal tutorial text
const C_CODE := "#ffcb6b"     # highlighted function names
const C_CODE_BG := "#3b3f4c"  # background behind highlighted code
const C_ARROW := "#88c0d0"    # tutorial bullet
const C_OUTPUT := "#a3be8c"   # print() output
const C_ERROR := "#ff6b6b"    # error text
const C_DIM := "#7a8194"      # labels and separators

var _tutorial: Array = []


func _ready() -> void:
	bbcode_enabled = true
	scroll_following = true
	selection_enabled = true
	
	add_theme_color_override("default_color", Color.WHITE)
	append_text("[color=#ff0000]test[/color]\n")



func set_tutorial(lines: Array) -> void:
	_tutorial = lines.duplicate()
	clear_log()


func clear_log() -> void:
	clear()
	for line in _tutorial:
		append_text("[color=%s]▸[/color] %s\n" % [C_ARROW, _fmt(str(line), C_TEXT)])
	if not _tutorial.is_empty():
		append_text("[color=%s]──────────────────[/color]\n" % C_DIM)


func print_line(t: String) -> void:
	append_text("[color=%s]OUTPUT[/color]  [color=%s]%s[/color]\n" % [C_DIM, C_OUTPUT, _esc(t)])


func error_line(line: int, message: String) -> void:
	var where := "line %d" % line if line > 0 else ""
	append_text("[color=%s][b]ERROR[/b][/color]  [color=%s]%s[/color]  %s\n" % [C_ERROR, C_DIM, where, _fmt(message, C_ERROR)])
	
func _fmt(t: String, base_color: String) -> String:
	var parts := t.split("`")
	var out := ""
	for i in parts.size():
		var seg := _esc(parts[i])
		if i % 2 == 1:
			out += "[bgcolor=%s][color=%s] %s [/color][/bgcolor]" % [C_CODE_BG, C_CODE, seg]
		else:
			out += "[color=%s]%s[/color]" % [base_color, seg]
	return out


func _esc(t: String) -> String:
	return t.replace("[", "[lb]")

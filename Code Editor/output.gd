class_name OutputLog
extends RichTextLabel

const C_TEXT := "#dde3dc"     # normal tutorial text
const C_CODE := "#4fd05a"     # highlighted function names
const C_CODE_BG := "#1c3d23"  # background behind inline code
const C_ARROW := "#f2902a"    # tutorial bullet
const C_OUTPUT := "#a8e6b0"   # print() output
const C_ERROR := "#e0484a"    # error text
const C_DIM := "#7d8883"      # labels and separators

const MIN_READY_WIDTH := 41.0 
const MAX_WAIT_FRAMES := 60

var _tutorial: Array = []
var _pending: Array[String] = []
var _flushing := false

var _token_re := RegEx.create_from_string("(#.*)|(\"[^\"]*\")|(\\b\\d+(?:\\.\\d+)?\\b)|(\\b[A-Za-z_]\\w*\\b)|([^\\w\\s])")


func _ready() -> void:
	bbcode_enabled = true
	scroll_following = true
	selection_enabled = true


func set_tutorial(lines: Array) -> void:
	_tutorial = lines.duplicate()
	clear_log()
	


func clear_log() -> void:
	clear()
	_pending.clear()

	var in_code := false
	var code_lines: Array[String] = []
	for line in _flatten(_tutorial):
		if line.strip_edges() == "```":
			if in_code:
				_write(_code_block(code_lines))
				code_lines.clear()
			in_code = not in_code
			continue
		if in_code:
			code_lines.append(line)
		elif line.strip_edges() == "":
			_write("\n")
		else:
			_write("[color=%s]▸[/color] %s\n" % [C_ARROW, _fmt(line, C_TEXT)])
	if in_code and not code_lines.is_empty():
		_write(_code_block(code_lines))

	if not _tutorial.is_empty():
		_write("[color=%s]──────────────────[/color]\n" % C_DIM)
	


func print_line(t: String) -> void:
	_write("[color=%s]OUTPUT[/color]  [color=%s]%s[/color]\n" % [C_DIM, C_OUTPUT, _esc(t)])


func error_line(line: int, message: String) -> void:
	var where := "line %d" % line if line > 0 else ""
	_write("[color=%s][b]ERROR[/b][/color]  [color=%s]%s[/color]  %s\n" % [C_ERROR, C_DIM, where, _fmt(message, C_ERROR)])



func _flatten(entries: Array) -> Array[String]:
	var out: Array[String] = []
	for e in entries:
		for l in str(e).split("\n"):
			out.append(l)
	return out


func _code_block(lines: Array[String]) -> String:
	var colored: Array[String] = []
	for l in lines:
		colored.append(_highlight(l))
	return "[table=1][cell bg=%s border=%s padding=10,6,10,6][code]%s[/code][/cell][/table]\n" % [
		CodeColors.hex(UIThemeBuilder.BG_DARK), CodeColors.hex(UIThemeBuilder.BORDER), "\n".join(colored)]


func _highlight(line: String) -> String:
	var out := ""
	var pos := 0
	for m in _token_re.search_all(line):
		out += _esc(line.substr(pos, m.get_start() - pos))
		var tok := m.get_string()
		var col := CodeColors.TEXT
		if m.get_string(1) != "":
			col = CodeColors.COMMENT
		elif m.get_string(2) != "":
			col = CodeColors.STRING
		elif m.get_string(3) != "":
			col = CodeColors.NUMBER
		elif m.get_string(4) != "":
			if CodeColors.KEYWORDS.has(tok):
				col = CodeColors.KEYWORDS[tok]
			elif line.substr(m.get_end(), 1) == "(":
				col = CodeColors.FUNCTION
		else:
			col = CodeColors.SYMBOL
		out += "[color=%s]%s[/color]" % [CodeColors.hex(col), _esc(tok)]
		pos = m.get_end()
	out += _esc(line.substr(pos))
	return out



func _write(bbcode: String) -> void:
	if _pending.is_empty() and _is_laid_out():
		append_text(bbcode)
		return
	_pending.append(bbcode)
	if not _flushing:
		_flush_when_ready()


func _is_laid_out() -> bool:
	return is_inside_tree() and size.x > MIN_READY_WIDTH


func _flush_when_ready() -> void:
	_flushing = true
	var waited := 0
	while not _is_laid_out() and waited < MAX_WAIT_FRAMES:
		await get_tree().process_frame
		waited += 1
	for bb in _pending:
		append_text(bb)
	_pending.clear()
	_flushing = false
	await get_tree().process_frame
	scroll_to_line(0)


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

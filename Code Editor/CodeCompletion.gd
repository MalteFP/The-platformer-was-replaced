class_name CodeCompletion
extends RefCounted

const KEYWORDS := {
	"for": "for",
	"while": "while",
	"if": "if",
	"else": "else",
	"func": "func",
	"return": "return",
	"true": "true",
	"false": "false",
}


const BUILTINS := {
	"print": ["print(value)", "print(|)"],
	"move_left": ["move_left()", "move_left()"],
	"move_right": ["move_right()", "move_right()"],
	"move_stop": ["move_stop()", "move_stop()"],
	"wait": ["wait(seconds)", "wait(|)"],
	"jump": ["jump(height)", "jump(|)"],
	"dash": ["dash(distance)", "dash(|)"],
}

const CARET := "\uFFFF"

var editor: CodeEdit
var _func_regex := RegEx.create_from_string("func\\s+([A-Za-z_]\\w*)\\s*\\(([^)]*)\\)")
var _var_regex := RegEx.create_from_string("(?m)^\\s*(?:for\\s+)?([A-Za-z_]\\w*)\\s*=(?!=)")


func attach(code_edit: CodeEdit) -> void:
	editor = code_edit

	editor.code_completion_enabled = true
	editor.code_completion_requested.connect(_on_completion_requested)
	editor.text_changed.connect(_on_text_changed)


	editor.add_comment_delimiter("#", "", true)
	editor.add_string_delimiter("\"", "\"", false)


	editor.auto_brace_completion_enabled = true
	editor.auto_brace_completion_highlight_matching = true
	editor.indent_automatic = true
	editor.indent_automatic_prefixes = ["{"]



func _on_text_changed() -> void:
	var line := editor.get_caret_line()
	var col := editor.get_caret_column()
	if col == 0:
		return
	if not editor.get_line(line)[col - 1].is_valid_identifier():
		return
	if editor.is_in_string(line, col) != -1 or editor.is_in_comment(line, col) != -1:
		return
	editor.request_code_completion(true)


func _on_completion_requested() -> void:
	var seen := {}

	for word in KEYWORDS:
		editor.add_code_completion_option(CodeEdit.KIND_PLAIN_TEXT, word,
				KEYWORDS[word].replace("|", CARET), Color.ORANGE)
		seen[word] = true

	for fn in BUILTINS:
		editor.add_code_completion_option(CodeEdit.KIND_FUNCTION, BUILTINS[fn][0],
				BUILTINS[fn][1].replace("|", CARET), Color.PURPLE)
		seen[fn] = true

	var source := editor.text


	for m in _func_regex.search_all(source):
		var fname := m.get_string(1)
		if seen.has(fname):
			continue
		seen[fname] = true
		var params := m.get_string(2).strip_edges()
		var insert := fname + ("(" + CARET + ")" if params != "" else "()")
		editor.add_code_completion_option(CodeEdit.KIND_FUNCTION,
				"%s(%s)" % [fname, params], insert, Color.MEDIUM_AQUAMARINE)


	for m in _var_regex.search_all(source):
		var vname := m.get_string(1)
		if seen.has(vname):
			continue
		seen[vname] = true
		editor.add_code_completion_option(CodeEdit.KIND_VARIABLE, vname, vname, Color.YELLOW)

	editor.update_code_completion_options(true)

class_name UIThemeBuilder
extends RefCounted
## Builds one dark theme for the whole UI. The palette matches OutputLog.gd.
## Edit the colors below and re-generate (see generate_theme.gd).
##
## Extra type variations (set "Theme Type Variation" on a node):
##   Button -> AccentButton      (filled primary button, e.g. Run)
##   Label  -> HeaderLabel       (big accent title)
##   Label  -> DimLabel          (muted helper text)

# ---------------------------------------------------------------- palette
const BG_DARK := Color("#1e222a")     # inputs, code editor, output
const BG := Color("#2e3440")          # panels
const BG_RAISED := Color("#3b4252")   # buttons
const BG_HOVER := Color("#434c5e")
const BORDER := Color("#4c566a")
const TEXT := Color("#d8dee9")
const TEXT_DIM := Color("#7a8194")
const ACCENT := Color("#88c0d0")
const ACCENT_DIM := Color("#5e81ac")
const ACCENT_DARK := Color("#3b5666")
const YELLOW := Color("#ffcb6b")
const RED := Color("#ff6b6b")
const GREEN := Color("#a3be8c")
const PURPLE := Color("#b48ead")

const FONT_SIZE := 16


static func build() -> Theme:
	var t := Theme.new()
	t.default_font_size = FONT_SIZE

	_buttons(t)
	_toggles(t)
	_labels(t)
	_line_edit(t)
	_text_edits(t)
	_rich_text(t)
	_panels(t)
	_scrollbars(t)
	_sliders_and_progress(t)
	_tabs(t)
	_popups(t)
	_lists_and_trees(t)
	_separators_and_splits(t)
	_variations(t)
	return t


## Syntax colors for the CodeEdit. Usage:
##   code_editor.syntax_highlighter = UIThemeBuilder.make_highlighter()
static func make_highlighter() -> CodeHighlighter:
	var h := CodeHighlighter.new()
	h.number_color = PURPLE
	h.symbol_color = TEXT_DIM
	h.function_color = ACCENT
	h.member_variable_color = TEXT
	for kw in ["for", "while", "if", "else", "func", "return"]:
		h.add_keyword_color(kw, YELLOW)
	for kw in ["true", "false"]:
		h.add_keyword_color(kw, PURPLE)
	for fn in ["print", "move_left", "move_right", "move_stop", "wait", "jump"]:
		h.add_keyword_color(fn, ACCENT)
	h.add_color_region("\"", "\"", GREEN, false)
	h.add_color_region("#", "", TEXT_DIM, true)
	return h


# ---------------------------------------------------------------- helpers

static func _box(bg: Color, border: Color = Color.TRANSPARENT, border_w := 0, radius := 6, pad_h := 12, pad_v := 8) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.border_color = border
	s.set_border_width_all(border_w)
	s.set_corner_radius_all(radius)
	s.content_margin_left = pad_h
	s.content_margin_right = pad_h
	s.content_margin_top = pad_v
	s.content_margin_bottom = pad_v
	return s


static func _focus_box(radius := 6) -> StyleBoxFlat:
	var s := _box(Color.TRANSPARENT, ACCENT, 2, radius)
	s.draw_center = false
	return s


static func _colors(t: Theme, type: String, d: Dictionary) -> void:
	for k in d:
		t.set_color(k, type, d[k])


static func _mono_font() -> SystemFont:
	var f := SystemFont.new()
	f.font_names = PackedStringArray(["JetBrains Mono", "Fira Code", "Cascadia Code", "Consolas", "Menlo", "DejaVu Sans Mono", "monospace"])
	return f


# --------------------------------------------------------------- controls

static func _buttons(t: Theme) -> void:
	for type in ["Button", "OptionButton", "MenuButton"]:
		t.set_stylebox("normal", type, _box(BG_RAISED, BORDER, 1))
		t.set_stylebox("hover", type, _box(BG_HOVER, ACCENT_DIM, 1))
		t.set_stylebox("pressed", type, _box(ACCENT_DARK, ACCENT, 1))
		t.set_stylebox("hover_pressed", type, _box(ACCENT_DARK, ACCENT, 1))
		t.set_stylebox("disabled", type, _box(BG, BG_RAISED, 1))
		t.set_stylebox("focus", type, _focus_box())
		_colors(t, type, {
			"font_color": TEXT,
			"font_hover_color": Color.WHITE,
			"font_pressed_color": ACCENT,
			"font_hover_pressed_color": ACCENT,
			"font_focus_color": TEXT,
			"font_disabled_color": TEXT_DIM,
		})
		t.set_constant("h_separation", type, 8)


static func _toggles(t: Theme) -> void:
	for type in ["CheckBox", "CheckButton"]:
		var flat := _box(Color.TRANSPARENT, Color.TRANSPARENT, 0, 6, 8, 5)
		var hover := _box(Color(1, 1, 1, 0.05), Color.TRANSPARENT, 0, 6, 8, 5)
		t.set_stylebox("normal", type, flat)
		t.set_stylebox("pressed", type, flat)
		t.set_stylebox("disabled", type, flat)
		t.set_stylebox("hover", type, hover)
		t.set_stylebox("hover_pressed", type, hover)
		t.set_stylebox("focus", type, _focus_box())
		_colors(t, type, {
			"font_color": TEXT,
			"font_hover_color": Color.WHITE,
			"font_pressed_color": TEXT,
			"font_hover_pressed_color": Color.WHITE,
			"font_focus_color": TEXT,
			"font_disabled_color": TEXT_DIM,
		})
		t.set_constant("h_separation", type, 10)


static func _labels(t: Theme) -> void:
	_colors(t, "Label", {"font_color": TEXT})
	t.set_stylebox("normal", "Label", StyleBoxEmpty.new())
	_colors(t, "LinkButton", {
		"font_color": ACCENT,
		"font_hover_color": Color.WHITE,
		"font_pressed_color": ACCENT_DIM,
	})


static func _line_edit(t: Theme) -> void:
	t.set_stylebox("normal", "LineEdit", _box(BG_DARK, BORDER, 1, 6, 10, 7))
	t.set_stylebox("focus", "LineEdit", _box(BG_DARK, ACCENT, 1, 6, 10, 7))
	t.set_stylebox("read_only", "LineEdit", _box(BG, BORDER, 1, 6, 10, 7))
	_colors(t, "LineEdit", {
		"font_color": TEXT,
		"font_uneditable_color": TEXT_DIM,
		"font_placeholder_color": TEXT_DIM,
		"caret_color": ACCENT,
		"selection_color": Color(ACCENT, 0.3),
	})


static func _text_edits(t: Theme) -> void:
	var mono := _mono_font()
	for type in ["TextEdit", "CodeEdit"]:
		t.set_stylebox("normal", type, _box(BG_DARK, BORDER, 1, 6, 8, 6))
		t.set_stylebox("focus", type, _box(BG_DARK, ACCENT_DIM, 1, 6, 8, 6))
		t.set_stylebox("read_only", type, _box(BG_DARK.darkened(0.15), BORDER, 1, 6, 8, 6))
		_colors(t, type, {
			"background_color": BG_DARK,
			"font_color": TEXT,
			"font_readonly_color": TEXT_DIM,
			"font_placeholder_color": TEXT_DIM,
			"selection_color": Color(ACCENT, 0.3),
			"caret_color": ACCENT,
			"caret_background_color": BG_DARK,
			# Subtle on purpose: the game highlights the running line itself
			# with set_line_background_color().
			"current_line_color": Color(1, 1, 1, 0.03),
			"word_highlighted_color": Color(ACCENT, 0.15),
			"search_result_color": Color(YELLOW, 0.2),
			"search_result_border_color": Color(YELLOW, 0.6),
		})
		t.set_constant("line_spacing", type, 4)
		t.set_font("font", type, mono)
		t.set_font_size("font_size", type, FONT_SIZE)

	_colors(t, "CodeEdit", {
		"line_number_color": TEXT_DIM,
		"code_folding_color": TEXT_DIM,
		"folded_code_region_color": Color(ACCENT, 0.15),
		"brace_mismatch_color": RED,
		"breakpoint_color": RED,
		"bookmark_color": YELLOW,
		"executing_line_color": Color(GREEN, 0.3),
		"completion_background_color": BG,
		"completion_selected_color": BG_HOVER,
		"completion_existing_color": Color(ACCENT, 0.15),
		"completion_scroll_color": Color(BORDER, 0.6),
		"completion_scroll_hovered_color": BORDER,
	})


static func _rich_text(t: Theme) -> void:
	t.set_stylebox("normal", "RichTextLabel", _box(BG_DARK, BORDER, 1, 6, 12, 10))
	t.set_stylebox("focus", "RichTextLabel", _focus_box())
	_colors(t, "RichTextLabel", {
		"default_color": TEXT,
		"selection_color": Color(ACCENT, 0.3),
	})
	t.set_font("mono_font", "RichTextLabel", _mono_font())
	t.set_constant("line_separation", "RichTextLabel", 3)


static func _panels(t: Theme) -> void:
	t.set_stylebox("panel", "Panel", _box(BG, BORDER, 1, 8))
	t.set_stylebox("panel", "PanelContainer", _box(BG, BORDER, 1, 8, 12, 12))
	t.set_stylebox("panel", "PopupPanel", _box(BG, BORDER, 1, 6, 6, 6))
	t.set_stylebox("panel", "TooltipPanel", _box(BG_DARK, ACCENT_DIM, 1, 4, 8, 5))
	_colors(t, "TooltipLabel", {"font_color": TEXT})


static func _scrollbars(t: Theme) -> void:
	for type in ["HScrollBar", "VScrollBar"]:
		t.set_stylebox("scroll", type, _box(Color(0, 0, 0, 0.18), Color.TRANSPARENT, 0, 4, 4, 4))
		t.set_stylebox("scroll_focus", type, _box(Color(0, 0, 0, 0.18), Color.TRANSPARENT, 0, 4, 4, 4))
		t.set_stylebox("grabber", type, _box(BORDER, Color.TRANSPARENT, 0, 4, 4, 4))
		t.set_stylebox("grabber_highlight", type, _box(ACCENT_DIM, Color.TRANSPARENT, 0, 4, 4, 4))
		t.set_stylebox("grabber_pressed", type, _box(ACCENT, Color.TRANSPARENT, 0, 4, 4, 4))


static func _sliders_and_progress(t: Theme) -> void:
	for type in ["HSlider", "VSlider"]:
		t.set_stylebox("slider", type, _box(BG_RAISED, Color.TRANSPARENT, 0, 3, 3, 3))
		t.set_stylebox("grabber_area", type, _box(ACCENT_DIM, Color.TRANSPARENT, 0, 3, 3, 3))
		t.set_stylebox("grabber_area_highlight", type, _box(ACCENT, Color.TRANSPARENT, 0, 3, 3, 3))

	t.set_stylebox("background", "ProgressBar", _box(BG_DARK, BORDER, 1, 6, 4, 6))
	t.set_stylebox("fill", "ProgressBar", _box(ACCENT, Color.TRANSPARENT, 0, 6, 4, 6))
	_colors(t, "ProgressBar", {"font_color": TEXT, "font_outline_color": BG_DARK})
	t.set_constant("outline_size", "ProgressBar", 3)


static func _tabs(t: Theme) -> void:
	for type in ["TabContainer", "TabBar"]:
		var selected := _box(BG, BORDER, 1, 6, 14, 8)
		selected.corner_radius_bottom_left = 0
		selected.corner_radius_bottom_right = 0
		var unselected := _box(BG_DARK, BORDER, 1, 6, 14, 8)
		unselected.corner_radius_bottom_left = 0
		unselected.corner_radius_bottom_right = 0
		var hovered := _box(BG_HOVER, BORDER, 1, 6, 14, 8)
		hovered.corner_radius_bottom_left = 0
		hovered.corner_radius_bottom_right = 0
		t.set_stylebox("tab_selected", type, selected)
		t.set_stylebox("tab_unselected", type, unselected)
		t.set_stylebox("tab_hovered", type, hovered)
		t.set_stylebox("tab_disabled", type, unselected)
		t.set_stylebox("tab_focus", type, _focus_box())
		_colors(t, type, {
			"font_selected_color": ACCENT,
			"font_unselected_color": TEXT_DIM,
			"font_hovered_color": TEXT,
			"font_disabled_color": TEXT_DIM,
		})
	t.set_stylebox("panel", "TabContainer", _box(BG, BORDER, 1, 6, 10, 10))


static func _popups(t: Theme) -> void:
	t.set_stylebox("panel", "PopupMenu", _box(BG, BORDER, 1, 6, 4, 4))
	t.set_stylebox("hover", "PopupMenu", _box(BG_HOVER, Color.TRANSPARENT, 0, 4, 8, 4))
	var line := StyleBoxLine.new()
	line.color = BORDER
	line.thickness = 1
	t.set_stylebox("separator", "PopupMenu", line)
	_colors(t, "PopupMenu", {
		"font_color": TEXT,
		"font_hover_color": Color.WHITE,
		"font_disabled_color": TEXT_DIM,
		"font_separator_color": TEXT_DIM,
		"font_accelerator_color": TEXT_DIM,
	})
	t.set_constant("h_separation", "PopupMenu", 10)
	t.set_constant("v_separation", "PopupMenu", 6)


static func _lists_and_trees(t: Theme) -> void:
	for type in ["ItemList", "Tree"]:
		t.set_stylebox("panel" if type == "Tree" else "panel", type, _box(BG_DARK, BORDER, 1, 6, 6, 6))
		t.set_stylebox("focus", type, _focus_box())
		t.set_stylebox("selected", type, _box(ACCENT_DARK, Color.TRANSPARENT, 0, 4, 6, 3))
		t.set_stylebox("selected_focus", type, _box(ACCENT_DARK, ACCENT, 1, 4, 6, 3))
		_colors(t, type, {
			"font_color": TEXT,
			"font_selected_color": Color.WHITE,
			"guide_color": Color(BORDER, 0.5),
		})
	t.set_stylebox("hovered", "ItemList", _box(Color(1, 1, 1, 0.05), Color.TRANSPARENT, 0, 4, 6, 3))
	_colors(t, "ItemList", {"font_hovered_color": Color.WHITE})
	t.set_stylebox("hovered", "Tree", _box(Color(1, 1, 1, 0.05), Color.TRANSPARENT, 0, 4, 6, 3))
	_colors(t, "Tree", {"font_hovered_color": Color.WHITE, "relationship_line_color": BORDER})


static func _separators_and_splits(t: Theme) -> void:
	var h := StyleBoxLine.new()
	h.color = BORDER
	h.thickness = 1
	t.set_stylebox("separator", "HSeparator", h)
	t.set_constant("separation", "HSeparator", 10)

	var v := StyleBoxLine.new()
	v.color = BORDER
	v.thickness = 1
	v.vertical = true
	t.set_stylebox("separator", "VSeparator", v)
	t.set_constant("separation", "VSeparator", 10)

	for type in ["HSplitContainer", "VSplitContainer"]:
		t.set_constant("separation", type, 8)
		t.set_constant("minimum_grab_thickness", type, 8)


static func _variations(t: Theme) -> void:
	# AccentButton: filled primary button
	t.set_type_variation("AccentButton", "Button")
	t.set_stylebox("normal", "AccentButton", _box(ACCENT, ACCENT, 1))
	t.set_stylebox("hover", "AccentButton", _box(ACCENT.lightened(0.15), ACCENT.lightened(0.15), 1))
	t.set_stylebox("pressed", "AccentButton", _box(ACCENT.darkened(0.2), ACCENT.darkened(0.2), 1))
	t.set_stylebox("hover_pressed", "AccentButton", _box(ACCENT.darkened(0.2), ACCENT.darkened(0.2), 1))
	_colors(t, "AccentButton", {
		"font_color": BG_DARK,
		"font_hover_color": BG_DARK,
		"font_pressed_color": BG_DARK,
		"font_hover_pressed_color": BG_DARK,
		"font_focus_color": BG_DARK,
	})

	# Labels
	t.set_type_variation("HeaderLabel", "Label")
	t.set_font_size("font_size", "HeaderLabel", 24)
	_colors(t, "HeaderLabel", {"font_color": ACCENT})

	t.set_type_variation("DimLabel", "Label")
	_colors(t, "DimLabel", {"font_color": TEXT_DIM})

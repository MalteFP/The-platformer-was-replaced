extends PanelContainer

@onready var title_bar: Control = $VBoxContainer/TitleBar
@onready var title_label: Label = $VBoxContainer/TitleBar/TitleLabel
@onready var title_edit: LineEdit = $VBoxContainer/TitleBar/TitleEdit
@onready var minimize_button: Button = $VBoxContainer/TitleBar/MinimizeButton
@onready var body: Control = $VBoxContainer/CodeEditor
@onready var footer: Control = $Footer
@onready var resize_handle: Control = $Footer/ResizeHandle

const MIN_WIDTH := 250.0
const MIN_BODY_HEIGHT := 100.0

var dragging := false
var drag_offset := Vector2.ZERO
var resizing := false
var minimized := false
var restored_height := 0.0

func _ready() -> void:
	custom_minimum_size.x = MIN_WIDTH
	body.custom_minimum_size.y = MIN_BODY_HEIGHT

	title_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title_edit.hide()

	resize_handle.gui_input.connect(_on_resize_input)
	minimize_button.pressed.connect(toggle_minimize)
	title_edit.text_submitted.connect(func(_t): _finish_rename())
	title_edit.focus_exited.connect(_finish_rename)

# ---------- drag + rename ----------

func _mouse_on_title() -> bool:
	var p = get_global_mouse_position()
	if not title_bar.get_global_rect().has_point(p):
		return false
	if minimize_button.get_global_rect().has_point(p):
		return false   # the button keeps its own clicks
	if title_edit.visible and title_edit.get_global_rect().has_point(p):
		return false   # let the user click inside the rename box
	return true

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and _mouse_on_title():
			if event.double_click:
				dragging = false
				_start_rename()
			else:
				move_to_front()
				dragging = true
				drag_offset = get_global_mouse_position() - global_position
			get_viewport().set_input_as_handled()
		elif not event.pressed:
			dragging = false
			resizing = false
	elif event is InputEventMouseMotion and dragging:
		var target = get_global_mouse_position() - drag_offset
		var limit = get_viewport_rect().size - Vector2(60, title_bar.size.y)
		global_position = target.clamp(Vector2(-size.x + 60, 0), limit)

func _start_rename() -> void:
	title_edit.text = title_label.text
	title_label.hide()
	title_edit.show()
	title_edit.grab_focus()
	title_edit.select_all()

func _finish_rename() -> void:
	if not title_edit.visible:
		return
	var new_title = title_edit.text.strip_edges()
	if new_title != "":
		title_label.text = new_title
	title_edit.hide()
	title_label.show()

# ---------- resize ----------

func _on_resize_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		resizing = event.pressed
	elif event is InputEventMouseMotion and resizing:
		size = get_global_mouse_position() - global_position

# ---------- minimize ----------

func toggle_minimize() -> void:
	minimized = not minimized
	if minimized:
		restored_height = size.y
		body.hide()
		footer.hide()
		size.y = 0
	else:
		body.show()
		footer.show()
		size.y = restored_height

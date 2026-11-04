extends Camera2D

var dragging := false
var last_mouse_pos := Vector2.ZERO

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			dragging = event.pressed
			last_mouse_pos = event.position

	if event is InputEventMouseMotion and dragging:
		var delta = event.position - last_mouse_pos
		position -= delta * 1/zoom
		last_mouse_pos = event.position

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom *= 1.1
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom *= 0.9

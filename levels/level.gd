extends Node
class_name level

@export var init_cam_zoom: Vector2
@export var init_cam_position: Vector2

func _ready() -> void:
	var cam: Camera2D = get_tree().get_first_node_in_group("player").cam
	cam.zoom = init_cam_zoom
	cam.position = init_cam_position


extends Camera2D

var camera_bounds: Polygon2D

var dragging := false


func _ready() -> void:
	camera_bounds = get_tree().get_first_node_in_group("Camera Bounds") as Polygon2D


	var region = get_valid_region(zoom)

	if region.size() < 3:
		push_error("Camera viewport does not fit inside CameraBounds!")


func _input(event: InputEvent) -> void:


	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			dragging = event.pressed

		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			change_zoom(zoom.x * 1.1)

		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			change_zoom(zoom.x * 0.9)

	if event is InputEventMouseMotion and dragging:
		var movement = (
			-event.relative / zoom
		).rotated(global_rotation)

		var target = global_position + movement
		var region = get_valid_region(zoom)

		if region.size() >= 3:
			global_position = camera_bounds.to_global(
				closest_point(camera_bounds.to_local(target), region)
			)



func get_valid_region(current_zoom: Vector2) -> PackedVector2Array:

	var polygon = camera_bounds.polygon
	var count = polygon.size()

	if count < 3:
		return PackedVector2Array()

	var half_size = (
		get_viewport_rect().size / current_zoom
	) / 2.0


	var camera_center = camera_bounds.to_local(global_position)

	var axis_x = (
		camera_bounds.to_local(
			global_position + Vector2.RIGHT.rotated(global_rotation) * half_size.x
		) - camera_center
	)

	var axis_y = (
		camera_bounds.to_local(
			global_position + Vector2.DOWN.rotated(global_rotation) * half_size.y
		) - camera_center
	)


	var area = polygon_area(polygon)
	var direction = 1.0 if area > 0.0 else -1.0


	var result = polygon.duplicate()


	for i in range(count):

		var a = polygon[i]
		var b = polygon[(i + 1) % count]

		var edge = b - a

		if edge.length_squared() < 0.000001:
			continue


		var normal = Vector2(-edge.y, edge.x).normalized() * direction


		var support = absf(normal.dot(axis_x)) + absf(normal.dot(axis_y))


		var threshold = normal.dot(a) + support

		result = clip_polygon(result, normal, threshold)

		if result.size() < 3:
			return PackedVector2Array()

	if absf(polygon_area(result)) < 0.000001:
		return PackedVector2Array()

	return result



func clip_polygon(
	polygon: PackedVector2Array,
	normal: Vector2,
	threshold: float
) -> PackedVector2Array:

	var output := PackedVector2Array()

	if polygon.is_empty():
		return output

	var previous = polygon[-1]
	var previous_inside = normal.dot(previous) >= threshold - 0.000001

	for current in polygon:

		var current_inside = normal.dot(current) >= threshold - 0.000001

		if current_inside != previous_inside:

			var direction = current - previous

			var denominator = normal.dot(direction)

			if absf(denominator) > 0.0000001:
				var t = (threshold - normal.dot(previous)) / denominator
				output.append(previous + direction * t)

		if current_inside:
			output.append(current)

		previous = current
		previous_inside = current_inside

	return output



func closest_point(point: Vector2, polygon: PackedVector2Array) -> Vector2:

	if Geometry2D.is_point_in_polygon(point, polygon):
		return point

	var best_point = polygon[0]
	var best_distance = INF

	for i in range(polygon.size()):

		var a = polygon[i]
		var b = polygon[(i + 1) % polygon.size()]

		var edge = b - a
		var length_squared = edge.length_squared()

		var t = 0.0

		if length_squared > 0.000001:
			t = clampf((point - a).dot(edge) / length_squared, 0.0, 1.0)

		var candidate = a + edge * t
		var distance = point.distance_squared_to(candidate)

		if distance < best_distance:
			best_distance = distance
			best_point = candidate

	return best_point


func change_zoom(target_zoom: float) -> void:

	var old_zoom = zoom.x

	if target_zoom <= 0.0:
		return

	if target_zoom >= old_zoom:
		zoom = Vector2.ONE * target_zoom
		return

	var requested_region = get_valid_region(Vector2.ONE * target_zoom)

	if requested_region.size() >= 3:
		zoom = Vector2.ONE * target_zoom
	else:

		# Find the minimum valid zoom.
		var low = target_zoom
		var high = old_zoom

		for i in range(24):
			var mid = (low + high) / 2.0

			var temp_region = get_valid_region(Vector2.ONE * mid)

			if temp_region.size() >= 3:
				high = mid
			else:
				low = mid

		zoom = Vector2.ONE * high

	var region = get_valid_region(zoom)

	if region.size() >= 3:
		var local_position = camera_bounds.to_local(global_position)

		global_position = camera_bounds.to_global(
			closest_point(local_position, region)
		)



func polygon_area(polygon: PackedVector2Array) -> float:

	var area = 0.0

	for i in range(polygon.size()):
		area += polygon[i].cross(polygon[(i + 1) % polygon.size()])

	return area / 2.0

extends Camera2D

@export var scroll_speed := 400.0           # how fast to pan
@export var edge_margin := 20               # distance from screen edge to start panning
@export var zoom_speed := 0.1               # how fast to zoom in/out
@export var min_zoom := Vector2(0.5, 0.5)   # minimum zoom in
@export var max_zoom := Vector2(2.0, 2.0)   # maximum zoom out

func _process(delta):
	var viewport_size = get_viewport_rect().size
	var mouse_pos = get_viewport().get_mouse_position()
	var move_dir = Vector2.ZERO

	# Move when mouse near screen edges
	if mouse_pos.x <= edge_margin:
		move_dir.x = -1
	elif mouse_pos.x >= viewport_size.x - edge_margin:
		move_dir.x = 1

	if mouse_pos.y <= edge_margin:
		move_dir.y = -1
	elif mouse_pos.y >= viewport_size.y - edge_margin:
		move_dir.y = 1

	# Normalize to prevent diagonal speed boost
	if move_dir != Vector2.ZERO:
		move_dir = move_dir.normalized()

	# Apply movement
	position += move_dir * scroll_speed * delta


func _unhandled_input(event):
	# Handle zoom with mouse wheel
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			zoom = (zoom - Vector2(zoom_speed, zoom_speed)).clamp(min_zoom, max_zoom)
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			zoom = (zoom + Vector2(zoom_speed, zoom_speed)).clamp(min_zoom, max_zoom)

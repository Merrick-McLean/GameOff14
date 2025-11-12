extends ActionState

var start_point: Vector2
var start_point_found := false
var preview_line: Line2D

func enter() -> void:
	preview_line = Line2D.new()
	preview_line.width = 4
	preview_line.default_color = Color(0.6, 0.3, 0.1)
	get_tree().get_current_scene().get_node("Level").add_child(preview_line)

func exit():
	# Clean up if we exit the state early
	if preview_line and preview_line.is_inside_tree():
		preview_line.queue_free()
	preview_line = null
	start_point_found = false

func handle_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var mouse_pos = get_global_mouse_position()
		if not start_point_found:
			start_point = mouse_pos
			start_point_found = true
			preview_line.points = [start_point, start_point]
		else:
			# clear preview line
			preview_line.points = []
			var end_point = mouse_pos
			call_firebreak(start_point, end_point)
			start_point_found = false
	
	elif event is InputEventMouseMotion and start_point_found:
		var mouse_pos = get_global_mouse_position()
		preview_line.points = [start_point, mouse_pos]

func call_firebreak(start: Vector2, end: Vector2) -> void:
	var firebreak = Line2D.new()
	firebreak.width = 6
	firebreak.default_color = Color(0.6, 0.3, 0.1)
	firebreak.points = [start, end]
	get_tree().get_current_scene().get_node("Level").add_child(firebreak)

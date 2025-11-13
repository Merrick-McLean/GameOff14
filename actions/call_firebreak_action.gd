extends ActionState

var max_length := 150
var max_trees := 40
var firebreak_thickness = 14
var start_point: Vector2
var start_point_found := false
var preview_line: Line2D

# TODO: Only allow clicks to occur within park level area and clamp line from displaying otside of area

func enter() -> void:
	preview_line = Line2D.new()
	preview_line.z_index = 1000
	preview_line.width = firebreak_thickness
	preview_line.default_color = Color(0.6, 0.3, 0.1, 0.5)
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
			var end_point = get_limited_point(mouse_pos)
			create_firebreak(start_point, end_point)
			start_point_found = false
	
	elif event is InputEventMouseMotion and start_point_found:
		var mouse_pos = get_global_mouse_position()
		var end_point = get_limited_point(mouse_pos)
		preview_line.points = [start_point, end_point]

func create_firebreak(start: Vector2, end: Vector2) -> void:
	var level = get_tree().get_current_scene().get_node("Level")
	
	# will probably remove when we get actual mechanic in - or will ust use preview
	var firebreak = Line2D.new()
	firebreak.z_index = 1000
	firebreak.width = firebreak_thickness
	firebreak.default_color = Color(0.6, 0.3, 0.1, 0.5)
	firebreak.points = [start, end]
	level.add_child(firebreak)
	
	var space_state = level.get_world_2d().direct_space_state
	
	var firebreak_shape = RectangleShape2D.new()
	var length = start.distance_to(end)
	firebreak_shape.extents = Vector2(length * 0.5, firebreak_thickness * 0.5)
	var mid_point = (start + end) * 0.5
	var angle = (end - start).angle()

	var params = PhysicsShapeQueryParameters2D.new()
	params.shape = firebreak_shape
	params.transform = Transform2D(angle, mid_point)
	params.collide_with_areas = false
	params.collide_with_bodies = true

	# Perform the intersection check
	var results = space_state.intersect_shape(params, max_trees)
	print(results)

	# work with a tick speed, not instantaneous
	for result in results:
		var collider = result.collider.get_parent()
		if collider and collider.has_method("chop_down"):
			collider.chop_down()

func get_limited_point(target_point: Vector2) -> Vector2:
	var direction = target_point - start_point
	var distance = direction.length()
	if distance > max_length:
		direction = direction.normalized() * max_length
		return start_point + direction
	return target_point

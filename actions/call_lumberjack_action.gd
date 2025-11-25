extends ActionState

@onready var action_manager = get_tree().get_current_scene().get_node("action_manager")
@onready var level_features = get_tree().get_current_scene().get_node("Level").get_node("Level_generate")

var target_lumberjack: Node2D = null

var start_point: Vector2
var start_point_found := false
var preview_line: Line2D

# TODO: Only allow clicks to occur within park level area and clamp line from displaying otside of area

func enter() -> void:
	var level = get_tree().get_current_scene().get_node("Level")
	
	preview_line = Line2D.new()
	preview_line.z_index = 1000
	preview_line.width = target_lumberjack.thickness
	preview_line.default_color = Color(0.6, 0.3, 0.1, 0.5)
	get_tree().get_current_scene().get_node("Level").add_child(preview_line)
	
	preview_line.visible = false

func exit():
	if preview_line and preview_line.is_inside_tree():
		preview_line.queue_free()
	preview_line = null
	
	start_point_found = false
	
	emit_signal("completed")

func handle_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var mouse_pos = get_global_mouse_position()
		if not start_point_found:
			start_point = mouse_pos
			start_point_found = true
			preview_line.points = [start_point, start_point]
			preview_line.visible = true
		else:
			preview_line.points = []
			var end_point = get_limited_point(mouse_pos)
			var tree_list = create_target_line(start_point, end_point)
			start_point_found = false
			
			target_lumberjack.target_list = tree_list
			target_lumberjack.target_line = [start_point, end_point]
			
			get_viewport().set_input_as_handled()
			var action = preload("res://actions/select_action.gd").new()
			action_manager.set_action_state(action)
	
	elif event is InputEventMouseMotion and start_point_found:
		var mouse_pos = get_global_mouse_position()
		var end_point = get_limited_point(mouse_pos)
		preview_line.points = [start_point, end_point]
	# add very short rectangle when starting point hasnt been selected, and also set same size rectangle to be minimum selection size
	# add handling so that selected area includes at least one tree - also solves water issue

func create_target_line(start: Vector2, end: Vector2) -> Array:
	var level = get_tree().get_current_scene().get_node("Level")
	
	var space_state = level.get_world_2d().direct_space_state
	
	var firebreak_shape = RectangleShape2D.new()
	var length = start.distance_to(end)
	firebreak_shape.extents = Vector2(length * 0.5, target_lumberjack.thickness * 0.5)
	var mid_point = (start + end) * 0.5
	var angle = (end - start).angle()

	var params = PhysicsShapeQueryParameters2D.new()
	params.shape = firebreak_shape
	params.transform = Transform2D(angle, mid_point)
	params.collide_with_areas = false
	params.collide_with_bodies = true

	var results = space_state.intersect_shape(params, target_lumberjack.max_trees)

	var tree_list = []
	for result in results:
		var collider = result.collider.get_parent()
		if collider and collider.has_method("chop"):
			tree_list.append(collider)
	return tree_list

func get_limited_point(target_point: Vector2) -> Vector2:
	var direction = target_point - start_point
	var distance = direction.length()
	if distance > target_lumberjack.max_length:
		direction = direction.normalized() * target_lumberjack.max_length
		return start_point + direction
	return target_point

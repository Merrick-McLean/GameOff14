extends ActionState

var max_trees := 40
var point_found := false
var preview_point: Node2D
var preview_radius: Node2D
var radius_val := 50.0

# TODO: Only allow clicks to occur within park level area and clamp line from displaying otside of area

func enter() -> void:
	var level = get_tree().get_current_scene().get_node("Level")

	preview_point = preload("res://actions/PreviewPoint.gd").new()
	preview_point.z_index = 1000
	preview_point.radius = 2.0
	preview_point.color = Color(0.1, 0.3, 0.6, 1.0)
	level.add_child(preview_point)
	level.add_child(preview_point)

	preview_radius = preload("res://actions/PreviewPoint.gd").new()
	preview_radius.z_index = 999
	preview_radius.radius = radius_val
	preview_radius.color = Color(0.1, 0.3, 0.6, 0.5)
	level.add_child(preview_radius)

func exit():
	# Clean up if we exit the state early
	if preview_point and preview_point.is_inside_tree():
		preview_point.queue_free()
	preview_point = null
	
	if preview_radius and preview_radius.is_inside_tree():
		preview_radius.queue_free()
	preview_radius = null
	
	point_found = false

func handle_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var mouse_pos = get_global_mouse_position()
		if not point_found:
			point_found = true
			preview_point.position = mouse_pos
			preview_point.queue_redraw()
			preview_radius.position = mouse_pos
			preview_radius.queue_redraw()
			create_water_drop(mouse_pos)
	elif event is InputEventMouseMotion and not point_found:
		var mouse_pos = get_global_mouse_position()
		preview_point.position = mouse_pos
		preview_point.queue_redraw()
		preview_radius.position = mouse_pos
		preview_radius.queue_redraw()

func create_water_drop(point: Vector2) -> void:
	var level = get_tree().get_current_scene().get_node("Level")
		
	var space_state = level.get_world_2d().direct_space_state
	var water_drop_shape = CircleShape2D.new()
	water_drop_shape.radius = radius_val

	var params = PhysicsShapeQueryParameters2D.new()
	params.shape = water_drop_shape
	params.transform = Transform2D(0, point)
	params.collide_with_areas = false
	params.collide_with_bodies = true

	# Perform the intersection check
	var results = space_state.intersect_shape(params, max_trees)
	print(results)

	# switch to dropping retardent
	for result in results:
		var collider = result.collider.get_parent()
		if collider and collider.has_method("retardent_cover"):
			collider.water_cover()

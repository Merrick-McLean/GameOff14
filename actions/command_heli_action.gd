extends ActionState

@onready var action_manager = get_tree().get_current_scene().get_node("action_controller")

# helicopter to command
var target_heli: Node2D = null

# tracks when point is clicked (necessary?)
var point_found := false

# positioning preview
var preview_point: Node2D
var preview_radius: Node2D
var radius_val: float

# TODO: Only allow clicks to occur within park level area and clamp line from displaying otside of area

func enter() -> void:
	"""
	
	"""
	var level = get_tree().get_current_scene().get_node("Level")

	preview_point = preload("res://actions/PreviewPoint.gd").new()
	preview_point.z_index = 1000
	preview_point.radius = 2.0
	preview_point.color = Color(0.1, 0.3, 0.6, 1.0)
	level.add_child(preview_point)
	level.add_child(preview_point)

	preview_radius = preload("res://actions/PreviewPoint.gd").new()
	preview_radius.z_index = 999
	preview_radius.radius = target_heli.radius_val
	preview_radius.color = Color(0.1, 0.3, 0.6, 0.5)
	level.add_child(preview_radius)

func exit():
	"""
	
	"""
	if preview_point and preview_point.is_inside_tree():
		preview_point.queue_free()
	preview_point = null
	
	if preview_radius and preview_radius.is_inside_tree():
		preview_radius.queue_free()
	preview_radius = null
	
	point_found = false
	
	emit_signal("completed")

func handle_input(event: InputEvent) -> void:
	"""
	
	"""
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var mouse_pos = get_global_mouse_position()
		if not point_found:
			point_found = true
			target_heli.target = mouse_pos
			var action = preload("res://actions/select_action.gd").new()
			action_manager.set_action_state(action)
	elif event is InputEventMouseMotion and not point_found:
		var mouse_pos = get_global_mouse_position()
		preview_point.position = mouse_pos
		preview_point.queue_redraw()
		preview_radius.position = mouse_pos
		preview_radius.queue_redraw()

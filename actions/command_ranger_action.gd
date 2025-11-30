extends ActionState

@onready var action_manager = get_tree().get_current_scene().get_node("action_manager")
@onready var level_features = get_tree().get_current_scene().get_node("Level").get_node("Level_generate")

# foam troop leader to command
var target_ranger: Node2D = null

# tracks when point is clicked
var point_found := false

# positioning preview
var preview_radius: Node2D

func enter() -> void:
	"""
	Function called when entering action to command the unit
	"""
	var level = get_tree().get_current_scene().get_node("Level")
	
	preview_radius = preload("res://actions/PreviewPoint.gd").new()
	preview_radius.z_index = 999
	preview_radius.radius = target_ranger.radius_val
	preview_radius.color = Color(0.1, 0.3, 0.6, 0.5)
	level.add_child(preview_radius)
	
	preview_radius.visible = false

func exit():
	"""
	Function called when command action is completed
	"""
	if preview_radius and preview_radius.is_inside_tree():
		preview_radius.queue_free()
	preview_radius = null
	
	point_found = false
	
	emit_signal("completed")

func handle_input(event: InputEvent) -> void:
	"""
	When click is made while in command action
	"""
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var mouse_pos = get_global_mouse_position()
		if not point_found:
			point_found = true
			target_ranger.target = mouse_pos
			
			get_viewport().set_input_as_handled()
			var action = preload("res://actions/select_action.gd").new()
			action_manager.set_action_state(action)
	elif event is InputEventMouseMotion and not point_found:
		preview_radius.visible = true
		var mouse_pos = get_global_mouse_position()
		preview_radius.position = mouse_pos
		preview_radius.queue_redraw()

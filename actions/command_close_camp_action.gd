extends ActionState

@onready var action_manager = get_tree().get_current_scene().get_node("action_manager")
@onready var level_features = get_tree().get_current_scene().get_node("Level").get_node("Level_generate")

# tracks when point is clicked
var point_found := false

var camp_radius_val := 45.0
var campsite_1: Node2D
var campsite_2: Node2D

func enter() -> void:
	var level = get_tree().get_current_scene().get_node("Level")
	var camps = level_features.camps
	
	if camps[0].open:
		campsite_1 = preload("res://actions/PreviewPoint.gd").new()
		campsite_1.z_index = 999
		campsite_1.radius = camp_radius_val
		campsite_1.color = Color(0.65, 0.6, 0.0, 0.5)
		campsite_1.global_position = camps[0].global_position
		level.add_child(campsite_1)
	
	if camps[1].open:
		campsite_2 = preload("res://actions/PreviewPoint.gd").new()
		campsite_2.z_index = 999
		campsite_2.radius = camp_radius_val
		campsite_2.color = Color(0.65, 0.6, 0.0, 0.5)
		campsite_2.global_position = camps[1].global_position
		level.add_child(campsite_2)
	
	return

func exit():
	if campsite_1 and campsite_1.is_inside_tree():
		campsite_1.queue_free()
	campsite_1 = null
	
	if campsite_2 and campsite_2.is_inside_tree():
		campsite_2.queue_free()
	campsite_2 = null
	
	point_found = false
	
	emit_signal("completed")

func handle_input(event: InputEvent) -> void:
	"""
	When click is made while in command action
	"""
	var camps = level_features.camps
	var level = get_tree().get_current_scene().get_node("Level")
	var mouse_pos = level.get_global_mouse_position()
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if campsite_1 and camps[0].open:
			if mouse_pos.distance_to(campsite_1.global_position) <= camp_radius_val:
				camps[0].close_camp()
				point_found = true
				
				get_viewport().set_input_as_handled()
				var action = preload("res://actions/select_action.gd").new()
				action_manager.set_action_state(action)
				return
		if campsite_2 and camps[1].open:
			if mouse_pos.distance_to(campsite_2.global_position) <= camp_radius_val:
				camps[1].close_camp()
				point_found = true
				
				get_viewport().set_input_as_handled()
				var action = preload("res://actions/select_action.gd").new()
				action_manager.set_action_state(action)
				return
	elif event is InputEventMouseMotion and not point_found:
		if campsite_1 and camps[0].open:
			if mouse_pos.distance_to(campsite_1.global_position) <= camp_radius_val:
				campsite_1.color = Color(1.0, 0.12, 0.1, 0.5)
				campsite_1.queue_redraw()
			else:
				campsite_1.color = Color(0.65, 0.6, 0.0, 0.5)
				campsite_1.queue_redraw()
		if campsite_2 and camps[1].open:
			if mouse_pos.distance_to(campsite_2.global_position) <= camp_radius_val:
				campsite_2.color = Color(1.0, 0.12, 0.1, 0.5)
				campsite_2.queue_redraw()
			else:
				campsite_2.color = Color(0.65, 0.6, 0.0, 0.5)
				campsite_2.queue_redraw()

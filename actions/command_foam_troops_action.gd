extends ActionState

@onready var action_manager = get_tree().get_current_scene().get_node("action_manager")
@onready var level_features = get_tree().get_current_scene().get_node("Level").get_node("Level_generate")

# foam troop leader to command
var target_leader: Node2D = null

# tracks when point is clicked
var point_found := false

# positioning preview
var preview_radius: Node2D

# TODO: Only allow clicks to occur within park level area and clamp line from displaying outside of area
# TODO: Do not allow clicks onto lakes (goes hand in hand with better path finding)

func enter() -> void:
	"""
	Function called when entering action to command the unit
	"""
	var level = get_tree().get_current_scene().get_node("Level")

	preview_radius = preload("res://actions/PreviewPoint.gd").new()
	preview_radius.z_index = 999
	preview_radius.radius = target_leader.radius_val
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
			target_leader.target = mouse_pos
			var trees_in_area = get_trees(mouse_pos)
			target_leader.target_list = sort_targets_by_distance(trees_in_area)
			
			get_viewport().set_input_as_handled()
			var action = preload("res://actions/select_action.gd").new()
			action_manager.set_action_state(action)
	elif event is InputEventMouseMotion and not point_found:
		preview_radius.visible = true
	
		var mouse_pos = get_global_mouse_position()
		preview_radius.position = mouse_pos
		preview_radius.queue_redraw()

# sort based on distance to leader, could sort dynaically during process of leader - based on hull or intensity or moisture or some calc
func sort_targets_by_distance(target_list):
	target_list.sort_custom(func(a, b):
		return a.global_position.distance_to(target_leader.lookout_pos) < b.global_position.distance_to(target_leader.lookout_pos)
	)
	return target_list

func get_trees(target):
	var level = get_tree().get_current_scene().get_node("Level")
	var space_state = level.get_world_2d().direct_space_state
	var foam_drop_shape = CircleShape2D.new()
	foam_drop_shape.radius = target_leader.radius_val

	var params = PhysicsShapeQueryParameters2D.new()
	params.shape = foam_drop_shape
	params.transform = Transform2D(0, target)
	params.collide_with_areas = false
	params.collide_with_bodies = true
	
	var tree_list = []
	var results = space_state.intersect_shape(params, target_leader.max_trees)
	for result in results:
		var tree = result.collider.get_parent()
		if tree and tree.has_method("douse_foam"):
			tree_list.append(tree)
	return tree_list

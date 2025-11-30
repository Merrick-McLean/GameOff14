extends Button

var plane_unit := preload("res://units/Plane.tscn")
const cost = 400

func _ready():
	"""
	
	"""
	pressed.connect(_on_button_pressed)
	tooltip_text = "Airtanker"

func _on_button_pressed():
	"""
	
	"""
	var game = get_tree().get_current_scene()
	var level = game.get_node("Level")
	var plane = plane_unit.instantiate()
	
	var action_manager = game.get_node("action_manager")
	var action = preload("res://actions/call_plane_action.gd").new()
	action.target_plane = plane
	action_manager.set_action_state(action)
	
	await action.completed
	
	var target_start = plane.target_line[0]
	var target_end = plane.target_line[1]
	plane.position = compute_spawn_from_target(level, plane, target_start, target_end)
	level.add_child(plane)
	var eco = get_tree().get_current_scene().get_node("UIEconomy")
	eco.cash -= cost

func compute_spawn_from_target(level, plane, target_start, target_end):
	var spawn_bounds: Rect2 = level.get_level_rect()
	var dir: Vector2 = (target_end - target_start).normalized()
	
	var max_dist: float = spawn_bounds.size.length()
	
	var spawn_point: Vector2 = target_start - dir * max_dist
	var despawn_point: Vector2 = target_end + dir * max_dist
	
	plane.destination = despawn_point
	return spawn_point

extends CanvasLayer

@onready var button = $Button
var helicopter := preload("res://units/Helicopter.tscn")

func _ready():
	"""
	
	"""
	button.pressed.connect(_on_button_pressed)

func _on_button_pressed():
	"""
	
	"""
	var game = get_tree().get_current_scene()
	var level = game.get_node("Level")
	var heli = helicopter.instantiate()
	
	var action_manager = game.get_node("action_manager")
	var action = preload("res://actions/command_heli_action.gd").new()
	action.target_heli = heli
	action_manager.set_action_state(action)
	
	await action.completed
	
	var target_dest = heli.target
	heli.position = compute_spawn_from_target(level, target_dest)
	level.add_child(heli)

func compute_spawn_from_target(level, target_pos):
	var rect: Rect2 = level.get_level_rect()
	
	var offset = 100
	var rand_offset = randf_range(-offset, offset)
	
	var left = Vector2(rect.position.x - offset, target_pos.y + rand_offset)
	var right = Vector2(rect.position.x + rect.size.x + offset, target_pos.y + rand_offset)
	var top = Vector2(target_pos.x + rand_offset, rect.position.y - offset)
	var bottom = Vector2(target_pos.x + rand_offset, rect.position.y + rect.size.y + offset)
	var candidates = [left, right, top, bottom]

	var min_point = null
	var min_dist = INF
	for c in candidates:
		var d = target_pos.distance_to(c)
		if d < min_dist:
			min_dist = d
			min_point = c
	
	return min_point

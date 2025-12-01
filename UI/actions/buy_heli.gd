extends Button

var helicopter := preload("res://units/Helicopter.tscn")
@onready var cost_text := $HeliCost
@onready var action_manager = get_tree().get_current_scene().get_node("action_manager")

const cost = 300

func _ready():
	"""
	
	"""
	pressed.connect(_on_button_pressed)
	tooltip_text = "Water Bomber" # possibly Helibucket instead?
	cost_text.text = "$" + str(cost)

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
	
	var ui = game.get_node("UIContainer")
	var eco = ui.get_node("UIEconomy")
	eco.cash -= cost
	eco.update()

func compute_spawn_from_target(level, target_pos):
	var spawn_bounds: Rect2 = level.get_level_rect()
	
	var offset = 100
	var rand_offset = randf_range(-offset, offset)
	
	var left = Vector2(spawn_bounds.position.x - offset, target_pos.y + rand_offset)
	var right = Vector2(spawn_bounds.position.x + spawn_bounds.size.x + offset, target_pos.y + rand_offset)
	var top = Vector2(target_pos.x + rand_offset, spawn_bounds.position.y - offset)
	var bottom = Vector2(target_pos.x + rand_offset, spawn_bounds.position.y + spawn_bounds.size.y + offset)
	var candidates = [left, right, top, bottom]

	var min_point = null
	var min_dist = INF
	for c in candidates:
		var d = target_pos.distance_to(c)
		if d < min_dist:
			min_dist = d
			min_point = c
	
	return min_point

func _process(delta: float) -> void:
	var game = get_tree().get_current_scene()
	var ui = game.get_node("UIContainer")
	var eco = ui.get_node("UIEconomy")
	if eco.cash < cost or action_manager.action_state is not SelectAction:
		disabled = true
		modulate = Color(0.3, 0.3 , 0.3)
	else: 
		disabled = false
		modulate = Color(1, 1 , 1)

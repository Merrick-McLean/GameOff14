extends Button

var lumberjack := preload("res://units/Lumberjack.tscn")

func _ready():
	"""
	
	"""
	pressed.connect(_on_button_pressed)

func _on_button_pressed():
	"""
	
	"""
	var game = get_tree().get_current_scene()
	var level = game.get_node("Level")
	var lumberjack = lumberjack.instantiate()
	
	var action_manager = game.get_node("action_manager")
	var action = preload("res://actions/call_lumberjack_action.gd").new()
	action.target_lumberjack = lumberjack
	action_manager.set_action_state(action)
	
	await action.completed
	
	lumberjack.position = compute_spawn_from_target(level)
	level.add_child(lumberjack)

func compute_spawn_from_target(level):
	return Vector2(200,200)

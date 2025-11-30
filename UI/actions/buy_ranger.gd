extends Button

var ranger_unit := preload("res://units/ranger.tscn")

func _ready():
	"""
	
	"""
	pressed.connect(_on_button_pressed)
	tooltip_text = "Park Ranger"

func _on_button_pressed():
	"""
	
	"""
	var game = get_tree().get_current_scene()
	var level = game.get_node("Level")
	var ranger = ranger_unit.instantiate()
	
	var action_manager = game.get_node("action_manager")
	var action = preload("res://actions/command_ranger_action.gd").new()
	action.target_ranger = ranger
	action_manager.set_action_state(action)
	
	await action.completed
	
	ranger.lookout_pos = compute_spawn_from_target(level)
	ranger.position = ranger.lookout_pos
	level.add_child(ranger)

func compute_spawn_from_target(level):
	var level_gen = level.get_node("Level_generate")
	return level_gen.lookout.global_position

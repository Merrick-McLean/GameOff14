extends Button

var foam_troop_leader := preload("res://units/foam_troop_leader.tscn")

func _ready():
	"""
	
	"""
	pressed.connect(_on_button_pressed)
	tooltip_text = "Foam Crew"

func _on_button_pressed():
	"""
	
	"""
	var game = get_tree().get_current_scene()
	var level = game.get_node("Level")
	var leader = foam_troop_leader.instantiate()
	
	var action_manager = game.get_node("action_manager")
	var action = preload("res://actions/command_foam_troops_action.gd").new()
	action.target_leader = leader
	action_manager.set_action_state(action)
	
	await action.completed
	
	leader.position = compute_spawn_from_target(level, leader)
	level.add_child(leader)

func compute_spawn_from_target(level, leader):
	return leader.lookout_pos

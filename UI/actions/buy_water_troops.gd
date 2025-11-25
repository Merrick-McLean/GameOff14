extends Button

var water_troop_leader := preload("res://units/water_troop_leader.tscn")

func _ready():
	"""
	
	"""
	pressed.connect(_on_button_pressed)
	tooltip_text = "Water Crew"

func _on_button_pressed():
	"""
	
	"""
	var game = get_tree().get_current_scene()
	var level = game.get_node("Level")
	var leader = water_troop_leader.instantiate()
	
	var action_manager = game.get_node("action_manager")
	var action = preload("res://actions/command_water_troops_action.gd").new()
	action.target_leader = leader
	action_manager.set_action_state(action)
	
	await action.completed
	
	leader.position = compute_spawn_from_target(level)
	level.add_child(leader)

func compute_spawn_from_target(level):
	return Vector2(200,200)

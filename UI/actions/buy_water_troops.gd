extends Button

var water_troop_leader := preload("res://units/water_troop_leader.tscn")
@onready var cost_text := $WaterTroopCost

const cost = 100

func _ready():
	"""
	
	"""
	pressed.connect(_on_button_pressed)
	tooltip_text = "Water Crew"
	cost_text.text = "$" + str(cost)

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
	
	leader.lookout_pos = compute_spawn_from_target(level)
	leader.position = leader.lookout_pos
	level.add_child(leader)
	var ui = game.get_node("UIContainer")
	var eco = ui.get_node("UIEconomy")
	eco.cash -= cost
	eco.update()

func compute_spawn_from_target(level):
	var level_gen = level.get_node("Level_generate")
	return level_gen.lookout.global_position

func _process(delta: float) -> void:
	var game = get_tree().get_current_scene()
	var ui = game.get_node("UIContainer")
	var eco = ui.get_node("UIEconomy")
	if eco.cash < cost:
		disabled = true
		modulate = Color(0.3, 0.3 , 0.3)
	else: 
		disabled = false
		modulate = Color(1, 1 , 1)

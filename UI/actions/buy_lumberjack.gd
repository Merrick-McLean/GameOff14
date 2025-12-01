extends Button

var lumberjack_unit := preload("res://units/Lumberjack.tscn")
@onready var cost_text := $LumberjackCost
@onready var action_manager = get_tree().get_current_scene().get_node("action_manager")

const cost = 100

func _ready():
	"""
	
	"""
	pressed.connect(_on_button_pressed)
	tooltip_text = "Lumberjack"
	cost_text.text = "$" + str(cost)

func _on_button_pressed():
	"""
	
	"""
	var game = get_tree().get_current_scene()
	var level = game.get_node("Level")
	var lumberjack = lumberjack_unit.instantiate()
	
	var action_manager = game.get_node("action_manager")
	var action = preload("res://actions/call_lumberjack_action.gd").new()
	action.target_lumberjack = lumberjack
	action_manager.set_action_state(action)
	
	await action.completed
	
	lumberjack.lookout_pos = compute_spawn_from_target(level)
	lumberjack.position = lumberjack.lookout_pos
	level.add_child(lumberjack)
	
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
	if eco.cash < cost or action_manager.action_state is not SelectAction:
		disabled = true
		modulate = Color(0.3, 0.3 , 0.3)
	else: 
		disabled = false
		modulate = Color(1, 1 , 1)
	

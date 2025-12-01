extends Button

@onready var cost_text := $CloseCampCost
@onready var action_manager = get_tree().get_current_scene().get_node("action_manager")

const cost = 0

func _ready():
	"""
	
	"""
	pressed.connect(_on_button_pressed)
	tooltip_text = "Shutdown Campsite"
	cost_text.text = "$" + str(cost)

func _on_button_pressed():
	"""
	
	"""
	var game = get_tree().get_current_scene()
	
	var action = preload("res://actions/command_close_camp_action.gd").new()
	action_manager.set_action_state(action)
	
	await action.completed
	
	var ui = game.get_node("UIContainer")
	var eco = ui.get_node("UIEconomy")
	eco.cash -= cost
	eco.update()

func _process(delta: float) -> void:
	var game = get_tree().get_current_scene()
	var ui = game.get_node("UIContainer")
	var eco = ui.get_node("UIEconomy")
	var camps = game.get_node("Level/Level_generate").camps
	
	var all_closed := true
	for camp in camps:
		if camp.open:
			all_closed = false
			break
	
	if eco.cash < cost or all_closed or action_manager.action_state is not SelectAction:
		disabled = true
		modulate = Color(0.3, 0.3 , 0.3)
	else: 
		disabled = false
		modulate = Color(1, 1 , 1)

extends Button

func _ready():
	"""
	
	"""
	pressed.connect(_on_button_pressed)
	tooltip_text = "Shutdown Campsite"

func _on_button_pressed():
	"""
	
	"""
	var game = get_tree().get_current_scene()
	
	var action_manager = game.get_node("action_manager")
	var action = preload("res://actions/command_close_camp_action.gd").new()
	action_manager.set_action_state(action)
	
	await action.completed

extends ActionState

@onready var action_manager = get_tree().get_current_scene().get_node("action_manager")

func enter() -> void:
	var level = get_tree().get_current_scene().get_node("Level")
	
	return

func exit():
	emit_signal("completed")

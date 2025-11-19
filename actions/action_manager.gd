extends Node2D

# ActionStates COMMAND_WATER, CALL_WATER, CALL_RET, CALL_FOAM, COMMAND_FOAM, BURN, BREAK 
# determines which action is being used
@export var action_state: ActionState = null
@export var currency := 0

func _unhandled_input(event):
	"""
	
	"""
	# at some point we need to contain that these only execute on the map
	if action_state:
		action_state.handle_input(event)

func set_action_state(new_state: ActionState):
	"""
	
	"""
	if action_state:
		action_state.exit()
		action_state.queue_free()
	
	self.action_state = new_state
	add_child(action_state)
	action_state.controller = self
	action_state.enter()


func is_select_state() -> bool:
	return true

extends Node2D

# ActionStates COMMAND_WATER, CALL_WATER, CALL_RET, CALL_FOAM, COMMAND_FOAM, BURN, BREAK 
# determines which action is being used
@export var action_state: ActionState = null

func _ready():
	set_action_state(preload("res://actions/firebreak_action.gd").new())

@export var currency := 0

func _unhandled_input(event):
	# at some point we need to contain that these only execute on the map
	# UI items should be built as nodes and be clickable internally
	# but UI elements/buttons should consume first, maybe no handling is necessary?
	if action_state:
		action_state.handle_input(event)

func set_action_state(new_state: ActionState):
	if action_state:
		action_state.exit()
		action_state.queue_free()
		
	action_state = new_state
	add_child(action_state)
	action_state.controller = self
	action_state.enter()

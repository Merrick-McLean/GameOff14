extends Node2D

@onready var action_manager = get_tree().get_current_scene().get_node("ActionManager")

func _ready():	
	# Ensure it has a clickable collider
	var area = $Area2D
	if area:
		area.input_pickable = true
		area.connect("input_event", Callable(self, "_on_input_event"))

func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		select_heli()

func select_heli():
	if action_manager:
		var new_action = preload("res://actions/command_heli_action.gd").new()
		action_manager.set_action_state(new_action)

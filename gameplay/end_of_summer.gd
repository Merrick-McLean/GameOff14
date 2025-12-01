extends CanvasLayer
var is_paused 

@onready var action_manager = get_tree().get_current_scene().get_node("action_manager")

func _ready():
	self.visible = false
	is_paused = false

func toggle_pause():
	if is_paused:
		Engine.time_scale = 1
		is_paused = false
	else:
		Engine.time_scale = 0
		is_paused = true

func activate(cash):
	despawn_troops()
	toggle_pause()
	
	
	
	self.visible = true
	var cash_text = $VBoxContainer/cash
	cash_text.text = str(cash)
	
	get_viewport().set_input_as_handled()
	var action = preload("res://actions/select_action.gd").new()
	action_manager.set_action_state(action)

func _input(event: InputEvent) -> void:
	if event.is_pressed() and event is InputEventKey or event is InputEventMouseButton or event is InputEventJoypadButton:
		if is_paused:
			toggle_pause()
			self.visible = false

func despawn_troops():
	for subtroop in get_tree().get_nodes_in_group("subtroops"):
		subtroop.queue_free()
	for troop in get_tree().get_nodes_in_group("troops"):
		troop.queue_free()

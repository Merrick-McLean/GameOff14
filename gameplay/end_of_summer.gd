extends CanvasLayer
var is_paused 
var is_game_over = false

@onready var action_manager = get_tree().get_current_scene().get_node("action_manager")
@onready var ui_container = get_tree().get_current_scene().get_node("UIContainer")

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

func activate(cash, score):
	ui_container.visible = false
	despawn_troops()
	toggle_pause()
	
	var trees = get_tree().get_nodes_in_group("trees")
	is_game_over = check_end_game(trees)
	
	self.visible = true
	
	if is_game_over:
		$VBoxContainer.visible = false
		$GameOver.visible = true
		$clickcont.visible = false
		var score_text = $GameOver/score
		score_text.text = "$" + str(int(score))
	else:
		$VBoxContainer.visible = true
		$GameOver.visible = false
		$clickcont.visible = true
		var cash_text = $VBoxContainer/cash
		cash_text.text = "$" + str(int(cash)) # in the future, a breakdown of wherethat money comes from would be good
	
	get_viewport().set_input_as_handled()
	var action = preload("res://actions/select_action.gd").new()
	action_manager.set_action_state(action)

func check_end_game(trees):
	if trees.is_empty():
		return true
		
	var burnt_count := 0
	for tree in trees:
		if tree.current_state == tree.state.burnt:
			burnt_count += 1
	var percent_burnt := float(burnt_count) / float(trees.size())
	
	return percent_burnt >= 0.75

func _input(event: InputEvent) -> void:
	if is_game_over:
		return
	
	if event.is_pressed() and event is InputEventKey or event is InputEventJoypadButton:
		if is_paused:
			toggle_pause()
			self.visible = false
			ui_container.visible = true

func despawn_troops():
	for subtroop in get_tree().get_nodes_in_group("subtroops"):
		subtroop.queue_free()
	for troop in get_tree().get_nodes_in_group("troops"):
		troop.queue_free()

extends Node2D

@onready var action_manager = get_tree().get_current_scene().get_node("action_manager")

# Variable to track the game state (paused or running)
var is_paused : bool = false

func _ready():
	# Initial setup: Game is not paused
	is_paused = false

func _process(_delta):
	if Input.is_action_just_pressed("ui_accept"):  
		toggle_pause()

func _input(_event):
	if Input.is_action_just_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		var action = preload("res://actions/select_action.gd").new()
		action_manager.set_action_state(action)

func toggle_pause():
	if is_paused:
		# Unpause the game
		Engine.time_scale = 1
		is_paused = false
	else:
		# Pause the game
		Engine.time_scale = 0
		is_paused = true

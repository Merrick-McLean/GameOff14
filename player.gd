extends Node2D

# Variable to track the game state (paused or running)
var is_paused : bool = false

# determines which action is being used
var action_mode := "chop"

func _ready():
	# Initial setup: Game is not paused
	is_paused = false

func _process(_delta):
	if Input.is_action_just_pressed("ui_accept"):  # "ui_accept" is the default action for spacebar
		toggle_pause()

func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		handle_action_click()

# Function to toggle the pause state
func toggle_pause():
	if is_paused:
		# Unpause the game
		Engine.time_scale = 1
		is_paused = false
	else:
		# Pause the game
		Engine.time_scale = 0
		is_paused = true

func handle_action_click():
	if is_paused:
		return
	
	match action_mode:
		"chop":
			handle_chop_click()
		_:
			return
			
func handle_chop_click():
	var click_pos = get_viewport().get_camera_2d().get_global_mouse_position()
	print("Click at:", click_pos)

	var space_state = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = click_pos
	query.collide_with_areas = true
	query.collide_with_bodies = true

	var result = space_state.intersect_point(query, 1)
	print("Result:", result)

	if result.size() > 0:
		var clicked = result[0].collider
		print("Clicked collider:", clicked)
		var parent = clicked.get_parent()
		if parent and parent.has_method("chop_down"):
			parent.chop_down()

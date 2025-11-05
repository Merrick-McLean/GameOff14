extends Node

# Variable to track the game state (paused or running)
var is_paused : bool = false

func _ready():
	# Initial setup: Game is not paused
	is_paused = false

func _process(_delta):
	if Input.is_action_just_pressed("ui_accept"):  # "ui_accept" is the default action for spacebar
		toggle_pause()

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

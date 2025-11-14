extends Node2D

@onready var action_manager = get_tree().get_current_scene().get_node("action_controller")
@onready var area = $Area2D

# target to drop water and source to get water
var target: Vector2
var source: Vector2

# water splash parameters
var max_trees := 40
var radius_val := 25.0

# helicopter movement
var max_speed := 75.0
var velocity: Vector2 = Vector2.ZERO
var acceleration_time := 0.25

# amount of fuel
var water_tank := 1.0
var fuel_tank := 1.0

func _ready():
	"""
	
	"""
	z_index = 1000
	area.input_pickable = true
	area.connect("input_event", Callable(self, "_on_input_event"))

func _on_input_event(viewport, event, shape_idx):
	"""
	
	"""
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		select_heli()
	elif event is InputEventMouseMotion:
		display_target()

func select_heli():
	"""
	
	"""
	if action_manager:
		var new_action = preload("res://actions/command_heli_action.gd").new()
		new_action.target_heli = self
		action_manager.set_action_state(new_action)

func display_target():
	# display the location of the current target on hover
	return

func create_water_drop(point: Vector2) -> void:
	"""
	
	"""
	var level = get_tree().get_current_scene().get_node("Level")
		
	var space_state = level.get_world_2d().direct_space_state
	var water_drop_shape = CircleShape2D.new()
	water_drop_shape.radius = radius_val

	var params = PhysicsShapeQueryParameters2D.new()
	params.shape = water_drop_shape
	params.transform = Transform2D(0, point)
	params.collide_with_areas = false
	params.collide_with_bodies = true

	# Perform the intersection check
	var results = space_state.intersect_shape(params, max_trees)
	print(results)

	# switch to delay this stuff, first create instance of heli scene to fly to point 
	for result in results:
		var collider = result.collider.get_parent()
		if collider and collider.has_method("water_cover"):
			collider.water_cover()

func _physics_process(delta: float) -> void:
	if target != null:
		move_towards_target(delta)

# still iffy about this, play around with more
func move_towards_target(delta: float) -> void:
	var direction := target - global_position
	var distance = direction.length()

	if distance < 1.0:
		velocity = Vector2.ZERO
		return 
	else:
		var cur_speed := max_speed
		var acceleration_distance := max_speed * acceleration_time
		if distance < acceleration_distance:
			cur_speed = lerp(5.0, max_speed, distance / acceleration_distance)
		
		velocity = velocity.move_toward(direction.normalized() * cur_speed, delta * 250) # as long as speed is big enough, doesnt seem to be much of a difference
		global_position += velocity * delta

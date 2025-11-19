extends Node2D

@onready var action_manager = get_tree().get_current_scene().get_node("action_controller")
@onready var level = get_tree().get_current_scene().get_node("Level")
@onready var area = $Area2D

# target to drop water and source to get water
var target: Vector2
var source: Vector2

# water splash parameters
var max_trees := 40
var radius_val := 25.0
var water_power := 0.5

# helicopter movement
var max_speed := 75.0
var velocity: Vector2 = Vector2.ZERO
var acceleration_time := 0.25

# amount of water supply
var water_tank := 1.0
var tank_use := 1.0 # if we make a use be less than a full tank, we will have to add a delay between drops
var refill_rate := 0.1
var refilling := false

func _ready():
	"""
	
	"""
	z_index = 1000
	area.input_pickable = true
	area.connect("input_event", Callable(self, "_on_input_event"))

# should the actual respons ena dactions like these occur on tick?
func _on_input_event(_viewport, event, _shape_idx):
	"""
	
	"""
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		select_heli()
	elif event is InputEventMouseMotion:
		display_target()

func _physics_process(delta: float) -> void:
	if target == null:
		return
	
	water_tank = clamp(water_tank, 0.0, 1.0)
	if refilling:
		refill_heli()
	elif water_tank < tank_use:
		if global_position.distance_to(source) > 1.0:
			move_towards_point(delta, source)
		else:
			refilling = true
	else:
		if global_position.distance_to(target) > 1.0:
			move_towards_point(delta, target)
		else:
			drop_water()

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

func refill_heli() -> void:
	if water_tank < 1.0:
		water_tank += refill_rate
	if water_tank >= 1.0:
		refilling = false
	return

func drop_water() -> void:
	"""
	
	"""
	# a delay is necessary for animation and such, currently instantaneous
	var water_dropped = false
			
	var space_state = level.get_world_2d().direct_space_state
	var water_drop_shape = CircleShape2D.new()
	water_drop_shape.radius = radius_val

	var params = PhysicsShapeQueryParameters2D.new()
	params.shape = water_drop_shape
	params.transform = Transform2D(0, target)
	params.collide_with_areas = false
	params.collide_with_bodies = true

	var results = space_state.intersect_shape(params, max_trees)
	for result in results:
		var tree = result.collider.get_parent()
		if tree and tree.on_fire and tree.has_method("douse_water"):
			tree.douse_water(water_power)
			water_dropped = true
	
	if water_dropped:
		water_tank -= tank_use

# still iffy about movement, play around with more
func move_towards_point(delta: float, point: Vector2) -> void:
	var direction := point - global_position
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

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
var speed := 75

# amount of fuel
var water_tank := 1.0
var fuel_tank := 1.0

func _ready():
	"""
	
	"""
	z_index = 1000
	area.input_pickable = true
	area.connect("input_event", Callable(self, "_on_input_event"))

func _on_input_event(event):
	"""
	
	"""
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		select_heli()

func select_heli():
	"""
	
	"""
	print("test")
	if action_manager:
		print("test2")
		var new_action = preload("res://actions/command_heli_action.gd").new()
		new_action.target_heli = self
		action_manager.set_action_state(new_action)
		
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
		
func move_towards_target(delta: float) -> void:
	var direction = (target - global_position)
	var distance = direction.length()

	if distance < 1.0:
		return  # close enough / arrived

	direction = direction.normalized()
	global_position += direction * speed * delta

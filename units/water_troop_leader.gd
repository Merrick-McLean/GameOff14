extends Node2D

@onready var action_manager = get_tree().get_current_scene().get_node("action_manager")
@onready var level = get_tree().get_current_scene().get_node("Level")

@onready var area = $Area2D
@onready var animation := $AnimatedSprite2D
@onready var water_tank_bar = $TextureProgressBar

# target to drop water and source to get water
var target: Vector2
var source: Vector2

var target_list: Array

# troop params
var radius_val := 40.0 # search for trees region
var troop_count := 4

# water troop movement
var max_speed := 25.0
var velocity: Vector2 = Vector2.ZERO
var acceleration_time := 0.25

# amount of water supply
var water_tank := 1.0
var tank_use := 0.05 # decide how to impliment (per tree or  per tick)
var refill_rate := 0.01
var refilling := false
var water_power := 0.05 # per tick

# hover graphics
var target_radius: Node2D
var source_radius: Node2D
var water_troop_radius: Node2D

func _ready():
	"""
	On ready function when helicopter is initialized
	Sets up Z vaue and connects to necessary input detection
	Sets up helper visuals
	"""
	z_index = 1000
	area.input_pickable = true
	area.connect("input_event", Callable(self, "_on_input_event"))
	prepare_displays()
	
	area.mouse_entered.connect(_on_hover_enter)
	area.mouse_exited.connect(_on_hover_exit)
	
	animation.play("hover")
	
	target_radius.visible = false
	source_radius.visible = false
	water_troop_radius.visible = false

func create_troops():
	# make troops to be commanded
	# they will wait for a command to go to a tree or to follow the leader
	return

func _on_input_event(_viewport, event, _shape_idx):
	"""
	On input events for interaction with water troops object
	On click sends to commands troops
	Onhover gives useful HUD highlights
	"""
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		command_leader()
	elif event is InputEventMouseMotion:
		_on_hover_enter()

func command_leader():
	"""
	Sends to command heli action state
	"""
	var new_action = preload("res://actions/command_water_troops_action.gd").new()
	new_action.target_heli = self
	action_manager.set_action_state(new_action)

func _physics_process(delta: float) -> void:
	"""
	process running always
	Logic for what the helicopters current action is
	either moving, between target and source, refilling or dropping water
	"""
	if target == null:
		return
	
	# progress bar
	water_tank_bar.value = water_tank * 100.0
	water_tank = clamp(water_tank, 0.0, 1.0)
	
	if refilling:
		refill_troops()
	elif water_tank < tank_use:
		if global_position.distance_to(source) > 1.0:
			move_towards_point(delta, source)
		else:
			refilling = true
	else:
		if global_position.distance_to(target) > 1.0:
			move_towards_point(delta, target)
		else:
			command_troops()

func command_troops():
	# query trees from tree list
	# sort by closest (or maybe moisture content, or maybe hull?)
	# the optimized would be to pick the one with least hull that can still be saved - i.e. calculate?
	# if one is on fire, go through troop list until one returns true and takes it
	return

func move_towards_point(delta: float, point: Vector2) -> void:
	"""
	Subroutine to move for path finding
	Switch to pathfinding and adjust movement behaviour for troops (currently moves like heli)
	Will need some support functions for identifying lake areas (and identifying rivers for water troops) for pathfinding 
	"""
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

func refill_troops() -> void:
	"""
	Subroutine when we have reached water source and need to fill up on water
	"""
	if water_tank < 1.0:
		water_tank += refill_rate
	if water_tank >= 1.0:
		refilling = false
	return

func _on_hover_enter():
	"""
	Visuals for when we hover on helicopter (while in free action mode)
	"""
	if action_manager.action_state is SelectAction:
		target_radius.visible = true
		source_radius.visible = true
		water_troop_radius.visible = true
				
		target_radius.position = target
		target_radius.queue_redraw()
		
		source_radius.position = source
		source_radius.queue_redraw()
		
		water_troop_radius.queue_redraw()

func _on_hover_exit():
	"""
	Hide visuals for heli
	"""
	target_radius.visible = false
	source_radius.visible = false
	water_troop_radius.visible = false

func prepare_displays():
	"""
	Prepares hover HUD
	"""
	target_radius = preload("res://actions/PreviewPoint.gd").new()
	target_radius.z_index = 999
	target_radius.radius = radius_val
	target_radius.color = Color(0.1, 0.3, 0.6, 0.5)
	level.add_child(target_radius)
	
	source_radius = preload("res://actions/PreviewPoint.gd").new()
	source_radius.z_index = 999
	source_radius.radius = radius_val
	source_radius.color = Color(0.1, 0.3, 0.6, 0.5)
	level.add_child(source_radius)
	
	water_troop_radius = preload("res://actions/PreviewPoint.gd").new()
	water_troop_radius.z_index = 999
	water_troop_radius.radius = radius_val - 5
	water_troop_radius.color = Color(0.65, 0.75, 0.25, 0.5)
	self.add_child(water_troop_radius)

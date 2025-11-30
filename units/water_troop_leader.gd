extends Node2D

@onready var action_manager = get_tree().get_current_scene().get_node("action_manager")
@onready var level = get_tree().get_current_scene().get_node("Level")

@onready var area = $Area2D
@onready var animation := $AnimatedSprite2D
@onready var water_tank_bar = $TextureProgressBar

var crew_member = preload("res://units/water_troop_crew.tscn")

# target to drop water and source to get water
var target: Vector2
var source: Vector2

# troop params
var max_trees := 40
var radius_val := 60.0 # search for trees region

var target_list: Array
var troop_count := 4
var troop_list: Array = []
var troop_status: Array = []

# water troop movement
var max_speed := 25.0
var velocity: Vector2 = Vector2.ZERO
var acceleration_time := 0.25

# amount of water supply
var water_tank := 1.0
var tank_use := 0.000005
var refill_rate := 0.01
var refilling := false
var water_power := 0.005 

# hover graphics
var target_radius: Node2D
var source_radius: Node2D
var water_troop_radius: Node2D

# home base
var lookout_pos: Vector2

func _ready():
	"""
	On ready function when helicopter is initialized
	Sets up Z vaue and connects to necessary input detection
	Sets up helper visuals
	"""
	area.input_pickable = true
	area.connect("input_event", Callable(self, "_on_input_event"))
	prepare_displays()
	
	area.mouse_entered.connect(_on_hover_enter)
	area.mouse_exited.connect(_on_hover_exit)
	
	target_radius.visible = false
	source_radius.visible = false
	water_troop_radius.visible = false
	
	create_troops()

func create_troops():
	troop_list.clear()
	troop_status.clear()
	
	for num in range(troop_count):
		var new_crew_member = crew_member.instantiate()
		new_crew_member.leader = self
		new_crew_member.id = num
		var coeff = even_or_odd_sign(num)
		var variance = Vector2((coeff * num) * 8, (-coeff * (troop_count - num)) * 8)
		new_crew_member.position = global_position + variance
		
		troop_status.append(false)
		troop_list.append(new_crew_member)
		level.add_child(new_crew_member)

func even_or_odd_sign(x: int) -> int:
	return 1 if x % 2 == 0 else -1

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
	new_action.target_leader = self
	action_manager.set_action_state(new_action)

func _physics_process(delta: float) -> void:
	"""
	process running always
	Logic for what the helicopters current action is
	either moving, between target and source, refilling or dropping water
	"""
	z_index = int(position.y) + 1
	if target == null:
		return
	
	# progress bar
	water_tank_bar.value = water_tank * 100.0
	water_tank = clamp(water_tank, 0.0, 1.0)
	
	if refilling:
		refill_troops()
		animation.play("idle")
	elif water_tank < tank_use: # need to add better handling for this/control of crew members - because right now they will get stuck with no tank left
		if global_position.distance_to(source) > 1.0:
			move_towards_point(delta, source)
		else:
			refilling = true
	else:
		if global_position.distance_to(target) > 1.0:
			move_towards_point(delta, target)
		else:
			command_troops()
			animation.play("idle")

func command_troops():
	if troop_status.has(false):
		for tree in target_list: # currently just starts with closest tree, no risk assessment or anything atm
			if tree.current_state == tree.state.on_fire and not tree.occupied:
				for id in range(troop_count):
					if !troop_status[id]:
						tree.occupied = true
						troop_list[id].target = tree
						troop_status[id] = true
						return # returns as it only commands one unit per process, could break otherwise

# PATH FINDING!!!!!
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
	else:
		var cur_speed := max_speed
		var acceleration_distance := max_speed * acceleration_time
		if distance < acceleration_distance:
			cur_speed = lerp(5.0, max_speed, distance / acceleration_distance)
		
		velocity = velocity.move_toward(direction.normalized() * cur_speed, delta * 250) # as long as speed is big enough, doesnt seem to be much of a difference
		global_position += velocity * delta
	
	animation.play("walk")
	if direction.x < 0:
		animation.flip_h = true
	elif direction.x > 0:
		animation.flip_h = false

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

extends Node2D

@onready var action_manager = get_tree().get_current_scene().get_node("action_manager")
@onready var level = get_tree().get_current_scene().get_node("Level")

@onready var area = $Area2D
@onready var animation := $AnimatedSprite2D
@onready var foam_tank_bar = $TextureProgressBar

var crew_member = preload("res://units/foam_troop_crew.tscn")

# target to drop foam and source to get foam
var target: Vector2
var source: Vector2

# troop params
var max_trees := 40
var radius_val := 40.0 # search for trees region

var target_list: Array
var troop_count := 4
var troop_list: Array = []
var troop_status: Array = []

# foam troop movement
var max_speed := 25.0
var velocity: Vector2 = Vector2.ZERO
var acceleration_time := 0.25

var travelling := false # temp fix

# amount of foam supply
var foam_tank := 1.0
var tank_use := 0.05 # decide how to impliment (per tree or per tick) - right now per tick
var foam_power := 0.08 # per tick 
# also need to add a max moisture or max amount applied per tree

# hover graphics
var target_radius: Node2D
var foam_troop_radius: Node2D

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
	
	animation.play("idle")
	
	target_radius.visible = false
	foam_troop_radius.visible = false
	
	lookout_pos = Vector2(200, 200)
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
	On input events for interaction with foam troops object
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
	var new_action = preload("res://actions/command_foam_troops_action.gd").new()
	new_action.target_leader = self
	action_manager.set_action_state(new_action)

func _physics_process(delta: float) -> void:
	"""
	process running always
	Logic for what the helicopters current action is
	either moving, between target and source, refilling or dropping foam
	"""
	z_index = int(position.y)
	if target == null:
		return
	
	# progress bar
	foam_tank_bar.value = foam_tank * 100.0
	foam_tank = clamp(foam_tank, 0.0, 1.0)
	
	if foam_tank < tank_use: # need to add better handling for this/control of crew members - because right now they will get stuck with no tank left
		return_foam_crew(delta)
	else:
		if global_position.distance_to(target) > 1.0:
			move_towards_point(delta, target)
			travelling = true
		else:
			command_troops()
			travelling = false

func return_foam_crew(delta): # need to also add handling to remove children - maybe add children as children to leader, rather than level?
	if global_position.distance_to(lookout_pos) > 1.0:
		move_towards_point(delta, lookout_pos)
	else:
		if target_radius and target_radius.is_inside_tree():
			target_radius.queue_free()
		target_radius = null
		
		if foam_troop_radius and foam_troop_radius.is_inside_tree():
			foam_troop_radius.queue_free()
		foam_troop_radius = null
		
		self.queue_free()

func command_troops():
	if troop_status.has(false):
		for tree in target_list:
			if tree.current_state == tree.state.on_fire:
				for id in range(troop_count):
					if !troop_status[id]:
						troop_list[id].target = tree
						troop_status[id] = true
						break # ensure this break is proper, do not want multiple troops going to same tree

# PATH FINDING!!!!!
func move_towards_point(delta: float, point: Vector2) -> void:
	"""
	Subroutine to move for path finding
	Switch to pathfinding and adjust movement behaviour for troops (currently moves like heli)
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

func _on_hover_enter():
	"""
	Visuals for when we hover on helicopter (while in free action mode)
	"""
	if action_manager.action_state is SelectAction:
		target_radius.visible = true
		foam_troop_radius.visible = true
				
		target_radius.position = target
		target_radius.queue_redraw()
				
		foam_troop_radius.queue_redraw()

func _on_hover_exit():
	"""
	Hide visuals for heli
	"""
	target_radius.visible = false
	foam_troop_radius.visible = false

func prepare_displays(): # could have a source as the lookout tower? seems unnnecessary
	"""
	Prepares hover HUD
	"""
	target_radius = preload("res://actions/PreviewPoint.gd").new()
	target_radius.z_index = 999
	target_radius.radius = radius_val
	target_radius.color = Color(0.1, 0.3, 0.6, 0.5)
	level.add_child(target_radius)
	
	foam_troop_radius = preload("res://actions/PreviewPoint.gd").new()
	foam_troop_radius.z_index = 999
	foam_troop_radius.radius = radius_val - 5
	foam_troop_radius.color = Color(0.65, 0.75, 0.25, 0.5)
	self.add_child(foam_troop_radius)

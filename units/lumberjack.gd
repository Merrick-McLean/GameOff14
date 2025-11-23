extends Node2D

# scenes
@onready var action_manager = get_tree().get_current_scene().get_node("action_manager")
@onready var level = get_tree().get_current_scene().get_node("Level")

# children
@onready var area = $Area2D
@onready var animation := $AnimatedSprite2D

# target to drop water and source to get water
var target_list: Array
var target_line: Array

# home base
var lookout_pos: Vector2

# chopping values
var chopping = false
var chop_time = 0.5

# Lumberjack movement
var max_speed := 25.0
var velocity: Vector2 = Vector2.ZERO
var acceleration_time := 0.25

# selection size
var max_length := 150
var max_trees := 40
var thickness = 14

# preview graphics
var lumberjack_radius: Node2D
var preview_line: Node2D
var radius_val := 5

func _ready():
	"""
	On ready function when helicopter is initialized
	Sets up Z vaue and connects to necessary input detection
	Sets up helper visuals
	"""
	area.input_pickable = true
	area.connect("input_event", Callable(self, "_on_input_event"))
	prepare_displays()
	
	lumberjack_radius.visible = false
	preview_line.visible = false
	
	area.mouse_entered.connect(_on_hover_enter)
	area.mouse_exited.connect(_on_hover_exit)
	
	animation.play("idle")
	
	lookout_pos = Vector2(200, 200)
	sort_targets_by_distance()

# need to handle stopping input when on water area
func _on_input_event(_viewport, event, _shape_idx):
	"""
	On input events for interaction with helicopter object
	Onhover gives useful HUD highlights
	"""
	if event is InputEventMouseMotion:
		_on_hover_enter()

func _physics_process(delta: float) -> void:
	"""
	process running always
	Logic for what the Lumberjack current action is
	either moving to tree or chopping tree
	"""
	z_index = int(position.y)
	if chopping:
		return
	
	if target_list == null or target_list.is_empty():
		return_lumberjack(delta)
		return
	
	# get position to target tree (could sort or something so they are in a line before?
	var target = target_list[0]
	var target_pos = target.global_position
	
	if target.on_fire or target.stump:
		target_list.pop_front()	
	elif global_position.distance_to(target_pos) > 1.0:
		move_towards_point(delta, target_pos)
	else:
		chop_tree(target)

func chop_tree(target_tree):
	chopping = true
	await get_tree().create_timer(chop_time).timeout
	target_tree.chop()
	target_list.pop_front()
	chopping = false

func return_lumberjack(delta):
	if global_position.distance_to(lookout_pos) > 1.0:
		move_towards_point(delta, lookout_pos)
	else:
		if preview_line and preview_line.is_inside_tree():
			preview_line.queue_free()
		preview_line = null
		
		if lumberjack_radius and lumberjack_radius.is_inside_tree():
			lumberjack_radius.queue_free()
		lumberjack_radius = null
		
		self.queue_free()

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

func sort_targets_by_distance():
	target_list.sort_custom(func(a, b):
		return a.global_position.distance_to(lookout_pos) < b.global_position.distance_to(lookout_pos)
	)

func _on_hover_enter():
	"""
	Visuals for when we hover over lumberjack (while in free action mode)
	"""
	if action_manager.action_state is SelectAction:
		lumberjack_radius.visible = true
		preview_line.visible = true
		
		lumberjack_radius.queue_redraw()

func _on_hover_exit():
	"""
	Hide visuals for lumberjack
	"""
	lumberjack_radius.visible = false
	preview_line.visible = false

func prepare_displays():
	"""
	Prepares hover HUD
	"""
	lumberjack_radius = preload("res://actions/PreviewPoint.gd").new()
	lumberjack_radius.z_index = 999
	lumberjack_radius.radius = radius_val
	lumberjack_radius.color = Color(0.1, 0.3, 0.6, 0.5)
	self.add_child(lumberjack_radius)
	
	preview_line = Line2D.new()
	preview_line.z_index = 1000
	preview_line.width = thickness
	preview_line.points = target_line
	preview_line.default_color = Color(0.6, 0.3, 0.1, 0.5)
	get_tree().get_current_scene().get_node("Level").add_child(preview_line)

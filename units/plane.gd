extends Node2D

# scenes
@onready var action_manager = get_tree().get_current_scene().get_node("action_manager")
@onready var level = get_tree().get_current_scene().get_node("Level")

@onready var area = $Area2D
@onready var animation := $AnimatedSprite2D

# target to chop trees
var target_list: Array
var target_line: Array
var destination: Vector2

# selection size
var max_length := 400
var max_trees := 200
var thickness = 40

# plane values
var speed := 275

# retardent values
# need to tweak
var fire_power = 15.0 # moisture to add to on fire trees
var non_fire_power = 4.0  # moisture to add to alive trees
var doused = false

# preview graphics
var preview_line: Node2D

# retardent graphics
var last_effect_pos: Vector2 = Vector2(INF, INF)
var effect_spacing := 50.0

func _ready():
	"""
	On ready function when plane is initialized
	Sets up Z vaue and connects to necessary input detection
	Sets up helper visuals
	"""
	z_index = 1500
	area.input_pickable = true
	area.connect("input_event", Callable(self, "_on_input_event"))
	prepare_displays()
	
	preview_line.visible = false
	
	area.mouse_entered.connect(_on_hover_enter)
	area.mouse_exited.connect(_on_hover_exit)
	
	animation.play("fly")
	
	apply_direction()

func _physics_process(delta: float) -> void:
	"""
	process running always
	Logic for what the Lumberjack current action is
	either moving to tree or chopping tree
	"""
	if destination == null:
		return
	
	move_towards_position(delta)
	check_target_line_status()

func move_towards_position(delta: float) -> void:
	var dir := destination - global_position
	var dist := dir.length()

	if dist <= speed * delta:
		global_position = destination
		despawn_plane()
		return
	global_position += dir.normalized() * speed * delta

func check_target_line_status() -> void:
	if target_line.size() < 2:
		despawn_plane()
	
	var a: Vector2 = target_line[0]
	var b: Vector2 = target_line[1]
	var progress: float = clamp((global_position - a).dot(b - a) / (b - a).length_squared(), 0.0, 1.0)
	
	#var closest: Vector2 = a + (b - a) * progress
	#var dist := global_position.distance_to(closest)
	# dist < 5.0
	if  progress > 0.0 and progress < 1.0 and last_effect_pos.distance_to(global_position) >= effect_spacing:
		last_effect_pos = global_position
		spawn_retardant_effect(a + (b - a) * progress)
	
	if progress == 1.0 and not doused:
		doused = true
		for tree in target_list:
			print(tree)
			tree.douse_retardent(fire_power, non_fire_power)

func despawn_plane():
	if preview_line and preview_line.is_inside_tree():
		preview_line.queue_free()
	preview_line = null
	
	self.queue_free()

func apply_direction() -> void:
	var dir = destination - global_position
	var max_tilt := deg_to_rad(30)
	var vertical_dir := dir.normalized().y 
	rotation = clamp(vertical_dir * max_tilt, -max_tilt, max_tilt)
	if destination.x < global_position.x:
		animation.flip_h = true
		rotation *= -1

func spawn_retardant_effect(pos: Vector2) -> void:
	var effect_scene := preload("res://units/PlaneRetardantEffect.tscn")
	var effect := effect_scene.instantiate()
	get_tree().current_scene.add_child(effect)
	effect.global_position = pos

func prepare_displays():
	"""
	Prepares hover HUD
	"""
	preview_line = Line2D.new()
	preview_line.z_index = 1000
	preview_line.width = thickness
	preview_line.points = target_line
	preview_line.default_color = Color(0.6, 0.3, 0.1, 0.5)
	get_tree().get_current_scene().get_node("Level").add_child(preview_line)

func _on_input_event(_viewport, event, _shape_idx):
	"""
	On input events for interaction with helicopter object
	Onhover gives useful HUD highlights
	"""
	if event is InputEventMouseMotion:
		_on_hover_enter()

func _on_hover_enter():
	"""
	Visuals for when we hover over plane (while in free action mode)
	"""
	if action_manager.action_state is SelectAction:
		preview_line.visible = true

func _on_hover_exit():
	"""
	Hide visuals for lumberjack
	"""
	preview_line.visible = false

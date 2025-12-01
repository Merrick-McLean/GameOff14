extends Node2D

@onready var action_manager = get_tree().get_current_scene().get_node("action_manager")
@onready var level = get_tree().get_current_scene().get_node("Level")

@onready var area = $Area2D
@onready var animation := $AnimatedSprite2D
@onready var ranger_prog_bar = $TextureProgressBar

# target to drop foam and source to get foam
var target: Vector2
var camp_target = null
var camp_position: Vector2 = Vector2.ZERO
var max_objects := 100

# troop params
var search_radius_val := 100.0
var ranger_radius_val := 35.0 # search for illegal camps region

# foam troop movement
var max_speed := 30.0
var velocity: Vector2 = Vector2.ZERO
var acceleration_time := 0.25

# amount of foam supply
var ranger_timer := 1.0
var ranger_use := 30 # how many seconds it will last

# hover graphics
var target_radius: Node2D
var ranger_radius: Node2D

# home base
var lookout_pos: Vector2

func _ready():
	"""
	On ready function when ranger is initialized
	Sets up and connects to necessary input detection
	Sets up helper visuals
	"""
	area.input_pickable = true
	area.connect("input_event", Callable(self, "_on_input_event"))
	prepare_displays()
	
	area.mouse_entered.connect(_on_hover_enter)
	area.mouse_exited.connect(_on_hover_exit)
	
	target_radius.visible = false
	ranger_radius.visible = false

func _on_input_event(_viewport, event, _shape_idx):
	"""
	On input events for interaction with ranger object
	On click sends to commands troops
	Onhover gives useful HUD highlights
	"""
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		command_ranger()
	elif event is InputEventMouseMotion:
		_on_hover_enter()

func command_ranger():
	"""
	Sends to command heli action state
	"""
	var new_action = preload("res://actions/command_ranger_action.gd").new()
	new_action.target_ranger = self
	action_manager.set_action_state(new_action)

func _physics_process(delta: float) -> void:
	"""
	process running always
	Logic for what the helicopters current action is
	either moving, between target and source, refilling or dropping foam
	"""
	z_index = int(position.y) + 1
	if target == null:
		return
	
	if ranger_timer <= 0: 
		return_ranger(delta)
	elif camp_target != null and camp_position != Vector2.ZERO:
		ranger_prog_bar.value = ranger_timer * 100.0
		ranger_timer -= 1.0 / (ranger_use *  60)
		ranger_timer = clamp(ranger_timer, 0.0, 1.0)
		if global_position.distance_to(camp_position) > 1.0:
			move_towards_point(delta, camp_position)
		else:
			animation.play("idle")
			camp_target.close_illegal_camp()
			camp_target = null
			camp_position = Vector2.ZERO
	else:
		if global_position.distance_to(target) > 1.0:
			move_towards_point(delta, target)
		else:
			ranger_prog_bar.value = ranger_timer * 100.0
			ranger_timer -= 1.0 / (ranger_use *  60)
			ranger_timer = clamp(ranger_timer, 0.0, 1.0)
			campsite_search()
			animation.play("idle")

func return_ranger(delta): # need to also add handling to remove children - maybe add children as children to leader, rather than level?
	if global_position.distance_to(lookout_pos) > 1.0:
		move_towards_point(delta, lookout_pos)
	else:
		if target_radius and target_radius.is_inside_tree():
			target_radius.queue_free()
		target_radius = null
		
		if ranger_radius and ranger_radius.is_inside_tree():
			ranger_radius.queue_free()
		ranger_radius = null
		
		self.queue_free() # should wait for foam crew to make it before we free him maybe

func campsite_search():
	var space_state = level.get_world_2d().direct_space_state
	var campsite_search_area = CircleShape2D.new()
	campsite_search_area.radius = search_radius_val

	var params = PhysicsShapeQueryParameters2D.new()
	params.shape = campsite_search_area
	params.transform = Transform2D(0, target)
	params.collide_with_areas = false
	params.collide_with_bodies = true
	
	var results = space_state.intersect_shape(params, max_objects)
	for result in results:
		var campsite = result.collider.get_parent()
		if campsite and campsite.has_method("close_illegal_camp"):
			camp_target = campsite
			camp_position = campsite.global_position
			return

func move_towards_point(delta: float, point: Vector2) -> void:
	"""
	Subroutine to move for path finding
	Switch to pathfinding and adjust movement behaviour for troops (currently moves like heli)
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

func _on_hover_enter():
	"""
	Visuals for when we hover on helicopter (while in free action mode)
	"""
	if action_manager.action_state is SelectAction:
		target_radius.visible = true
		ranger_radius.visible = true
				
		target_radius.position = target
		target_radius.queue_redraw()
				
		ranger_radius.queue_redraw()

func _on_hover_exit():
	"""
	Hide visuals for heli
	"""
	target_radius.visible = false
	ranger_radius.visible = false

func prepare_displays(): # could have a source as the lookout tower? seems unnnecessary
	"""
	Prepares hover HUD
	"""
	target_radius = preload("res://actions/PreviewPoint.gd").new()
	target_radius.z_index = 999
	target_radius.radius = search_radius_val
	target_radius.color = Color(0.1, 0.3, 0.6, 0.5)
	level.add_child(target_radius)
	
	ranger_radius = preload("res://actions/PreviewPoint.gd").new()
	ranger_radius.z_index = 999
	ranger_radius.radius = ranger_radius_val
	ranger_radius.color = Color(0.65, 0.75, 0.25, 0.5)
	self.add_child(ranger_radius)

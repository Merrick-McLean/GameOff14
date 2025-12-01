extends Node2D

@onready var animation := $AnimatedSprite2D
@onready var foam_box := $Foam
@onready var foam := $Foam/AnimatedFoam2D

var leader: Node2D
var target: Node2D

var id: int

# foam troop movement
var max_speed := 24.0 # slightly slower than leader
var velocity: Vector2 = Vector2.ZERO
var acceleration_time := 0.25

var variance
var tree_distance_threshold := 10.0

var current_moisture_contribution = 0.0
var max_moisture_contribution = 1.0
var time_to_foam: float = 3.0
var foam_power: float = max_moisture_contribution / (60 * time_to_foam)

func _ready():
	add_to_group("subtroops")
	
	foam_box.visible = false
	foam.play("spray")
	foam.pause()
	
	var coeff = even_or_odd_sign(id)
	variance = Vector2((coeff * id) * 4, (-coeff * (leader.troop_count - id)) * 4)

func _physics_process(delta: float) -> void:
	z_index = int(position.y) + 1
	if target == null:
		if global_position.distance_to(leader.position + variance) > 1.0:
			move_towards_point(delta, leader.position + variance)
		else:
			animation.play("idle")
	else:
		if global_position.distance_to(target.position) > tree_distance_threshold:
			move_towards_point(delta, target.position)
		else:
			animation.play("idle")
			if target.current_state == target.state.alive and not target.protected and leader.foam_tank > 0:
				if current_moisture_contribution < max_moisture_contribution:
					spray_foam()
				else:
					target.protect()
			else: 
				if target.protected or target.current_state != target.state.alive or leader.foam_tank <= 0:
					current_moisture_contribution = 0.0
					target.occupied = false
					leader.troop_status[id] = false
					target = null
					foam_box.visible = false
					foam.stop()

func even_or_odd_sign(x: int) -> int:
	return 1 if x % 2 == 0 else -1

func spray_foam():
		if not foam.is_playing():
			foam_box.visible = true
			foam.play("spray")
			var dir = (target.global_position - global_position)
			foam_box.rotation = dir.angle()
		target.douse_foam(foam_power) 
		current_moisture_contribution += foam_power
		leader.foam_tank -= (foam_power / max_moisture_contribution) / leader.tank_use

func move_towards_point(delta: float, point: Vector2) -> void:
	"""
	Subroutine to move for path finding
	Switch to pathfinding and adjust movement behaviour for troops (currently moves like heli)
	Will need some support functions for identifying lake areas (and identifying rivers for foam troops) for pathfinding 
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

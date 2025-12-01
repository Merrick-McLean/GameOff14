extends Node2D

#  FIX RADIUSES AND TANK VALUES

@onready var animation := $AnimatedSprite2D
@onready var water_box := $Water
@onready var water := $Water/AnimatedWater2D

var leader: Node2D
var target: Node2D

var id: int

# water troop movement
var max_speed := 24.0 # slightly slower than leader
var velocity: Vector2 = Vector2.ZERO
var acceleration_time := 0.25

var variance
var tree_distance_threshold := 10.0

func _ready():
	water_box.visible = false
	water.play("spray")
	water.pause()
	
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
			if target.current_state == target.state.on_fire and leader.water_tank > 0:
				spray_tree()
			else: 
				if target.current_state != target.state.on_fire or leader.water_tank <= 0:
					leader.troop_status[id] = false
					target.occupied = false
					target = null
					water_box.visible = false
					water.stop()

func even_or_odd_sign(x: int) -> int:
	return 1 if x % 2 == 0 else -1

func spray_tree():
	if not water.is_playing():
		water_box.visible = true
		water.play("spray")
		var dir = (target.global_position - global_position)
		water_box.rotation = dir.angle()
	target.douse_water(leader.water_power) 
	leader.water_tank -= leader.tank_use

# need to add some variance and lag to the movement - makes it more interesting
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

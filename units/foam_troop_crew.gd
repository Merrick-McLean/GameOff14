extends Node2D

@onready var animation := $AnimatedSprite2D

var leader: Node2D
var target: Node2D

var id: int
var coeff

# foam troop movement
var max_speed := 25.0
var velocity: Vector2 = Vector2.ZERO
var acceleration_time := 0.25

var leader_distance_threshold := 20.0
var tree_distance_threshold := 10.0


func _ready():
	coeff = even_or_odd_sign(id)
	animation.play("idle")

# need to add communication between this and leader
# is there a better way to do this? function call that triggers it rather than waiting in loop?
func _physics_process(delta: float) -> void:
	z_index = int(position.y)
	if target == null:
		if leader.travelling and global_position.distance_to(leader.position) > leader_distance_threshold:
			var variance := Vector2(randf_range(-10, 10), randf_range(-10, 10)) # needs to improve... this following logic in general
			move_towards_point(delta, leader.position + variance)
		elif not leader.travelling: # if we dont check for leader_travelling, they just move as a pack, could be kinda cool ig too. lots to play around with
			# depends if we want them to travel in line (use traveling/elif) or as a pack (else statement, no travelling)... - higher chance of clumping in a line
			var variance = Vector2((coeff * id) * 4, (-coeff * (leader.troop_count - id)) * 4)
			if global_position.distance_to(leader.position + variance) > 1.0:
				move_towards_point(delta, leader.position + variance)
	else:
		if global_position.distance_to(target.position) > tree_distance_threshold:
			move_towards_point(delta, target.position)
		else:
			if target.current_state == target.state.alive and not target.protected: # nothing is stopping multiple troops from latching to a tree, should add "occupied" status to tree script
				# should apply protected bool once finished - also need a max amount we can apply
				target.douse_foam(leader.foam_power) # currently they do not move back to the leader util the tree is out, should they abandon trees?
				leader.foam_tank -= leader.tank_use # probably unsafe, untested
			else: 
				leader.troop_status[id] = false
				target = null

func even_or_odd_sign(x: int) -> int:
	return 1 if x % 2 == 0 else -1

# need to add some variance and lag to the movement - makes it more interesting
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
		return 
	else:
		var cur_speed := max_speed - (1.25 * id)
		var acceleration_distance := max_speed * acceleration_time
		if distance < acceleration_distance:
			cur_speed = lerp(5.0, max_speed, distance / acceleration_distance)
		
		velocity = velocity.move_toward(direction.normalized() * cur_speed, delta * 250) # as long as speed is big enough, doesnt seem to be much of a difference
		global_position += velocity * delta

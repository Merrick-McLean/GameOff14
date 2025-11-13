extends Node2D
var fire_reach = 30
@export var fire_spread = 0.99
var neighbors = []
var on_fire
var burnt
var other_trees = []
var _timer: Timer
var burn_interval = 10
var camp_tree = false
@export var camp_fire = 0.99


func _ready():
	var world_timer = get_tree().get_current_scene().get_node("Level/world_timer")
	world_timer.tick.connect(_on_tick)
	
func setup():
	on_fire = false
	burnt = false
	for tree in other_trees:
		if is_within_distance(self, tree, fire_reach):
			neighbors.append(tree)
	#bug testing
	"""
		if not on_fire and randf() > 0.99:
		self.ignite()
	
	"""

func _on_tick():
	if on_fire:
		for tree in neighbors:
			if not (tree is Polygon2D):
				if not tree.on_fire and not tree.burnt and randf() > fire_spread:
					tree.ignite()
	elif camp_tree:
		if randf() > camp_fire:
			self.ignite()

func is_within_distance(node_a: Node2D, node_b: Node2D, radius: float) -> bool:
	var distance = node_a.global_position.distance_to(node_b.global_position)
	return distance <= radius

func ignite():
	self.modulate = Color(1,0,0)
	on_fire = true
	queue_redraw()
	_timer = Timer.new()
	_timer.wait_time = burn_interval
	_timer.one_shot = false
	_timer.autostart = true

	# connect the timer's timeout signal to tick signal
	_timer.timeout.connect(_on_timer_timeout)
	add_child(_timer)
	

func burn_out():
	self.modulate = Color()
	on_fire = false
	burnt = true
	queue_redraw()

func _on_timer_timeout():
	burn_out()
	queue_redraw()

func _draw() -> void:
	if on_fire:
		draw_circle(Vector2(), 40, Color(1,0,0))

func chop_down():
	print("chopped")
	return

func retardent_cover():
	print("covered")
	return

func water_cover():
	print("covered")
	return

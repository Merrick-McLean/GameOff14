extends Node2D

var _timer: Timer

# fire capabilities
var fire_reach = 30
@export var fire_spread = 0.99

# tree references
var tree_type
var neighbors = []
var other_trees = []

# camp trees
var camp_tree = false
@export var camp_fire = 0.99

# fire states
var on_fire = false
var burnt = false
var protected = false # to mark when a tree has been foamed by a troop

# burn stats
var burn_rate = 0.01
var burn_interval = 10
var moisture = 1.0 
var hull = 1.0

# extinguish trackers - to be removed in favour of moisture
var extinguish_prog = 0.0
var extinguish_prog_loss = 0.05 # perhaps extinguish progress is lost if you stop extinguishing
var exitnguish_prog_buffer = 5 # number of ticks before extinguish progress begins to deplete

func _ready():
	var world_timer = get_tree().get_current_scene().get_node("Level/world_timer")
	world_timer.tick.connect(_on_tick)
	
	var weather = get_tree().get_current_scene().get_node("Level/weather_control")
	weather.wet_wave.connect(_wet_wave) 
	#weather.storm_wave.connect(_storm_wave) 
	#weather.heat_wave.connect(_heat_wave) 
	
func setup():
	on_fire = false
	burnt = false
	for tree in other_trees:
		if is_within_distance(self, tree, fire_reach):
			neighbors.append(tree)

func _on_tick():
	if burnt: 
		return
	if on_fire:
		# Merrick (note to self): should be reducing extinguish progress if not currently being extinguished after short delay
		return 
	if moisture <= 0:
		self.ignite()
	elif camp_tree:
		if randf() > camp_fire:
			self.ignite()
	else:
		for tree in neighbors:
			if tree.on_fire:
				moisture -= burn_rate 

func is_within_distance(node_a: Node2D, node_b: Node2D, radius: float) -> bool:
	var distance = node_a.global_position.distance_to(node_b.global_position)
	return distance <= radius

func ignite():
	self.modulate = Color(1,0,0)
	on_fire = true
	queue_redraw()
	_timer = Timer.new()
	# i think we could add some variance to burn interval as well
	# this could make the game feel more dynamic, if we dont use moisture as HP it could factor into this as well!
	_timer.wait_time = burn_interval 
	_timer.one_shot = false
	_timer.autostart = true

	# connect the timer's timeout signal to tick signal
	_timer.timeout.connect(_on_timer_timeout)
	add_child(_timer)

func set_texture(idx : int):
	idx = idx%3
	tree_type = idx
	var new_texture
	match tree_type:
		0:
			new_texture = load("res://assets/Trees/Pine/PineTree.png")
		1:
			new_texture = load("res://assets/Trees/Birch/BirchTree.png")
		2:
			new_texture = load("res://assets/Trees/Oak/OakTree.png")
	$Sprite2D.texture = new_texture

func burn_out():
	on_fire = false
	burnt = true
	var new_texture
	match tree_type:
		0:
			new_texture = load("res://assets/Trees/Pine/PineTreeBurnt.png")
		1:
			new_texture = load("res://assets/Trees/Birch/BirchTreeBurnt.png")
		2:
			new_texture = load("res://assets/Trees/Oak/OakTreeBurnt.png")
	$Sprite2D.texture = new_texture

func _on_timer_timeout():
	burn_out()
	queue_redraw()

func _draw() -> void:
	if on_fire:
		draw_circle(Vector2(), 40, Color(1,0,0))

func chop():
	var new_texture
	match tree_type:
		0:
			new_texture = load("res://assets/Trees/Pine/PineTreeStump.png")
		1:
			new_texture = load("res://assets/Trees/Birch/BirchTreeStump.png")
		2:
			new_texture = load("res://assets/Trees/Oak/OakTreeStump.png")
	$Sprite2D.texture = new_texture
	return

func douse_water(power):
	extinguish_prog += power
	if extinguish_prog >= 1.0:
		extinguish()

func extinguish():
	_timer.stop()
	on_fire = false
	extinguish_prog = 0.0
	moisture = 1.0 # up for debate
	self.modulate = Color(1, 1, 1, 1)
	queue_redraw()

func _wet_wave():
	moisture += 1.0

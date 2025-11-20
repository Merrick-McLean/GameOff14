extends Node2D

var _timer: Timer

# fire capabilities
var fire_reach = 30
# tree references
var tree_type
var neighbors = []
var other_trees = []

# camp trees
var camp_tree = false
@export var camp_fire = 0.99

# fire states
enum state {
	alive,
	recoverable,
	burnt
}
var on_fire

var current_state: state = state.alive

# burn stats
var burn_rate = 0.1
var burn_spread_chance = 0.055
var hull = 100.0

var evaporate = 0.00001
var moisture = 0.1

# extinguish trackers
var extinguish_prog = 0.0
var extinguish_prog_loss = 0.05 # perhaps extinguish progress is lost if you stop extinguishing
var exitnguish_prog_buffer = 5 # number of ticks before extinguish progress begins to deplete

func _ready():
	var world_timer = get_tree().get_current_scene().get_node("Level/world_timer")
	world_timer.tick.connect(_on_tick)
	
	var weather = get_tree().get_current_scene().get_node("Level/weather_control")
	weather.relax.connect(_relax)
	weather.wet_wave.connect(_wet_wave) 
	#weather.storm_wave.connect(_storm_wave) 
	weather.heat_wave.connect(_heat_wave) 
	
func setup():
	on_fire = false
	if camp_tree:
		ignite()
	for tree in other_trees:
		if is_within_distance(self, tree, fire_reach):
			neighbors.append(tree)

func _on_tick():
	match current_state:
		state.alive:
			for tree in neighbors:
				if tree.on_fire:
					moisture -= evaporate
					if randf() > 1 - burn_spread_chance + moisture:
						ignite()
		state.recoverable:
			if hull < 0:
				burn_out()
			elif hull > 0 and moisture > burn_rate:
				recover()
			else:
				hull -= max(0.01, burn_rate - moisture)
				for tree in neighbors:
					if tree.on_fire:
						moisture -= evaporate
		state.burnt:
			pass
	
	
func is_within_distance(node_a: Node2D, node_b: Node2D, radius: float) -> bool:
	var distance = node_a.global_position.distance_to(node_b.global_position)
	return distance <= radius

func ignite():
	self.modulate = Color(1,0,0)
	on_fire = true
	current_state = state.recoverable
	queue_redraw()

func recover():
	on_fire = false
	self.modulate = Color(1,1,1)
	var new_texture
	match tree_type:
		0:
			new_texture = load("res://assets/Trees/Pine/PineTree.png")
		1:
			new_texture = load("res://assets/Trees/Birch/BirchTree.png")
		2:
			new_texture = load("res://assets/Trees/Oak/OakTree.png")
	$Sprite2D.texture = new_texture
	queue_redraw()
			
func burn_out():
	on_fire = false
	current_state = state.burnt
	var new_texture

	match tree_type:
		0:
			new_texture = load("res://assets/Trees/Pine/PineTreeBurnt.png")
		1:
			new_texture = load("res://assets/Trees/Birch/BirchTreeBurnt.png")
		2:
			new_texture = load("res://assets/Trees/Oak/OakTreeBurnt.png")
	$Sprite2D.texture = new_texture
	queue_redraw()
		
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

#signals for weather
func _relax():
	evaporate = 0.00001

func _wet_wave():
	moisture += 0.1
	
func _heat_wave():
	evaporate *= 1.5

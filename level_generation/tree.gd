extends Node2D

var _timer: Timer

# fire capabilities
var fire_reach = 20
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
	on_fire,
	burnt
}
var current_state: state = state.alive

# burn stats
var burn_rate = 0.005
var burn_spread_chance = 0.0005
var hull = 1.0
var intensity = 0.0
var evaporate = 0.0001
var moisture = 0.02

func _ready():
	var world_timer = get_tree().get_current_scene().get_node("Level/world_timer")
	world_timer.tick.connect(_on_tick)
	
	var weather = get_tree().get_current_scene().get_node("Level/weather_control") # node that provides sigals for diffrent weather types
	weather.relax.connect(_relax)
	weather.wet_wave.connect(_wet_wave) 
	#weather.storm_wave.connect(_storm_wave) 
	weather.heat_wave.connect(_heat_wave) 
	
func setup():
	#runs after all trees made
	for tree in other_trees:
		if is_within_distance(self, tree, fire_reach):
			neighbors.append(tree) #calc trees close enough to affect 

func _on_tick():
	match current_state: #state machine
		state.alive:
			for tree in neighbors:
				if tree.current_state == state.on_fire:
					moisture -= evaporate
					if randf() > 1 - burn_spread_chance:
						ignite()
		state.on_fire: 
			intensity = sin(hull*PI + 0.3)*3/5 + 0.4 - max(moisture, 0)
			print(intensity)
			if intensity <= 0:
				if hull > 0:
					recover()
					return
				else:
					burn_out()
					return
			hull -= burn_rate
			moisture -= evaporate/(1-intensity)
			for tree in neighbors:
				if tree.current_state == state.on_fire:
					moisture -= evaporate
		state.burnt: 
			pass
	
	
func is_within_distance(node_a: Node2D, node_b: Node2D, radius: float) -> bool: #are two nodes close enough together?
	var distance = node_a.global_position.distance_to(node_b.global_position)
	return distance <= radius

func ignite(): #called when a tree is offically on fire
	self.modulate = Color(1,0,0)
	current_state = state.on_fire
	queue_redraw()

func recover(): #called when a tree was on fire but not burnt
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
			
func burn_out(): # called when a tree dies
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

func _draw() -> void: # make the fire circle
	if current_state == state.on_fire:
		draw_circle(Vector2(), 40, Color(1,0,0))

func chop(): # chop tree
	burn_out() # stop affecting everything around you
	var new_texture
	match tree_type:
		0:
			new_texture = load("res://assets/Trees/Pine/PineTreeStump.png")
		1:
			new_texture = load("res://assets/Trees/Birch/BirchTreeStump.png")
		2:
			new_texture = load("res://assets/Trees/Oak/OakTreeStump.png")
	$Sprite2D.texture = new_texture
	stump = true

# decide whether to handle state check here or on troop side...
func douse_water(power):
	moisture += power

func douse_foam(power):
	moisture += power

func douse_retardent(power):
	moisture += power

#signals for weather
func _relax():
	evaporate = 0.00001 # back to normal

func _wet_wave(): # make the trees wetter
	moisture += 0.1
	
func _heat_wave(): # double evap while heat wave - a but of const moist once
	moisture -= 0.01
	evaporate *= 2

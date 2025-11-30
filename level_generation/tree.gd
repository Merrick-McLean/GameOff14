extends Node2D
# fire capabilities
var fire_reach = 30
# tree references
var tree_type
var neighbors = []
var other_trees = []

# camp trees
var camp_tree = false
@export var camp_fire = 0.99
var seed




# fire states
enum state {
	alive,
	on_fire,
	burnt,
	stump
}
var current_state: state = state.alive

# additional state which is exclusive with alive
var protected = false
var occupied = false

# burn stats
var burn_rate = 0.0001
var burn_spread_chance = 0.001
var hull = 1.0
var intensity = 0.0
var evaporate = 0.1
var moisture = 0.1

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
			intensity = sin(hull*PI + 0.3)*3/5 + 0.4 - max(moisture, 0) * 0.1
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
		state.burnt or state.stump: 
			pass
	
func is_within_distance(node_a: Node2D, node_b: Node2D, radius: float) -> bool: #are two nodes close enough together?
	var distance = node_a.global_position.distance_to(node_b.global_position)
	return distance <= radius

func ignite(): #called when a tree is offically on fire
	self.modulate = Color(1,0,0)
	current_state = state.on_fire
	queue_redraw()

func recover(): #called when a tree was on fire but not burnt
	self.modulate = get_parent().get_color_for_index(seed)
	current_state = state.alive
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
		var center := Vector2(0,1)
		var base_r := 40
		draw_circle(center, base_r * 0.9, Color(1, 0.1, 0.1, 0.7))

func chop(): # chop tree
	var new_texture
	match tree_type:
		0:
			new_texture = load("res://assets/Trees/Pine/PineTreeStump.png")
		1:
			new_texture = load("res://assets/Trees/Birch/BirchTreeStump.png")
		2:
			new_texture = load("res://assets/Trees/Oak/OakTreeStump.png")
	$Sprite2D.texture = new_texture
	current_state = state.stump
	queue_redraw()

# decide whether to handle state check here or on troop side...
func douse_water(power):
	if current_state == state.on_fire:
		moisture += power

func douse_foam(power):
	if current_state == state.alive and not protected:
		moisture += power

func douse_retardent(fire_power, non_fire_power):
	if current_state == state.on_fire:
		moisture += fire_power
	elif current_state == state.alive and not protected:
		protect(false)
		moisture += non_fire_power

func protect(foam):
	protected = true
	if foam:
		draw_circle(Vector2(0,1), 40 * 0.9, Color(0.6, 0.35, 0.55, 0.7))
	else: #ie retardent
		draw_circle(Vector2(0,1), 40 * 0.9, Color(0.55, 0.05, 0.15, 0.7))
	queue_redraw()

#signals for weather
func _relax():
	evaporate = 0.00001 # back to normal

func _wet_wave(): # make the trees wetter
	moisture += 0.1
	
func _heat_wave(): # double evap while heat wave - a but of const moist once
	moisture -= 0.01
	evaporate *= 2

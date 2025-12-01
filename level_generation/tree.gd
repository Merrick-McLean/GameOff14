extends Node2D

@onready var burn_anim = $Burn
@onready var ignite_anim = $Ignite
@onready var tree_sprite = $Sprite2D

#TODO: Known issue, all sprites for trees (different species, stumps, burnt, alive) are not all aligned from base
# this causes hit box/sprite to be slightly off depending
# e.g. hit box is set up for oak tree, birch tree and pine tree will be slightly lower
# e.g. switching from alive oak to burnt oak makes sprite move slightly

# trees having different stats would be cool :)

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

var rain = 0

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

# burn stat
var burn_rate = 0.001 # doubled here
var burn_spread_chance = 0.0003
var hull = 1.0
var intensity = 0.1
var evaporate = 0.00001
var moisture = 0.2

func _ready():
	var world_timer = get_tree().get_current_scene().get_node("Level/world_timer")
	world_timer.tick.connect(_on_tick)
	
	var weather = get_tree().get_current_scene().get_node("Level/weather_control") # node that provides sigals for diffrent weather types
	weather.relax.connect(_relax)
	weather.wet_wave.connect(_wet_wave) 
	weather.heat_wave.connect(_heat_wave) 
	
	ignite_anim.animation_finished.connect(_on_ignite_finished)
	ignite_anim.visible = false
	burn_anim.visible = false

func setup():
	#runs after all trees made
	for tree in other_trees:
		if is_within_distance(self, tree, fire_reach):
			neighbors.append(tree) #calc trees close enough to affect 

func _on_tick():
	moisture += rain - evaporate/10
	match current_state: #state machine
		state.alive:
			for tree in neighbors:
				if tree.current_state == state.on_fire:
					moisture -= evaporate
					if randf() > 1 - burn_spread_chance:
						ignite()
		state.on_fire: 
			intensity = sin(hull*PI + 0.3)*3/5 + 0.4 - max(moisture, 0)
			if intensity <= 0:
				if hull > 0:
					recover()
					return
				else:
					burn_out()
					return
			hull -= burn_rate
			moisture -= evaporate
			for tree in neighbors:
				if tree.current_state == state.on_fire:
					moisture -= evaporate
		state.burnt or state.stump: 
			pass
	
func is_within_distance(node_a: Node2D, node_b: Node2D, radius: float) -> bool: #are two nodes close enough together?
	var distance = node_a.global_position.distance_to(node_b.global_position)
	return distance <= radius

func ignite(): #called when a tree is offically on fire
	tree_sprite.modulate = Color(0.8, 0.3, 0.0, 1.0)
	current_state = state.on_fire
	queue_redraw()
	
	ignite_anim.visible = true
	burn_anim.visible = false
	ignite_anim.play("ignite")

func _on_ignite_finished():
	if current_state != state.on_fire:
		return
	ignite_anim.visible = false
	burn_anim.visible = true
	burn_anim.play("burn")   # set to loop in the spriteframes

func stop_fire_animations():
	ignite_anim.stop()
	burn_anim.stop()
	ignite_anim.visible = false
	burn_anim.visible = false

func recover(): #called when a tree was on fire but not burnt
	stop_fire_animations()
	tree_sprite.modulate = get_parent().get_color_for_index(seed)
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
	stop_fire_animations()
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
	if current_state == state.alive and protected:
		draw_circle(Vector2(0,1), 40 * 0.9, Color(0.6, 0.35, 0.55, 0.7))

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
		protect()
		moisture += non_fire_power

func protect():
	protected = true
	queue_redraw()

#signals for weather
func _relax():
	evaporate = 0.00001 # back to normal
	rain	 = 0
func _wet_wave(): # make the trees wetter
	rain = 0.00001
	
func _heat_wave(): # double evap while heat wave - a but of const moist once
	evaporate *= 2

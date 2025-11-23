extends Node2D

var trees = []

var campers = []
var fire_chance = 0
var open = true

@export var max_campers = 10
@onready var camper_scene: PackedScene = preload("res://level_generation/camper.tscn")
func _ready():
	var world_timer = get_tree().get_current_scene().get_node("Level/world_timer")
	world_timer.tick.connect(_on_tick)
	z_index = global_position.y
	spawn_camper()

func _on_tick():
	var n = randf()
	if n < 0.001*campers.size():
		light_tree()
	elif n < 0.01 and campers.size() < max_campers:
		spawn_camper()
		
func spawn_camper():
	var camper = camper_scene.instantiate()
	camper.z_index = global_position.y
	add_child(camper)
	campers.append(camper)

func light_tree():
	if campers.size() > 0 and trees.size() > 0:
		campers.pick_random().go_light(trees.pick_random())
		

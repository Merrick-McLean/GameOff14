extends Node2D

var campers = 0
var fire_chance = 0
var open = true
@onready var camper_scene: PackedScene = preload("res://level_generation/camper.tscn")
func _ready():
	var world_timer = get_tree().get_current_scene().get_node("Level/world_timer")
	world_timer.tick.connect(_on_tick)
	spawn_camper()
	z_index = global_position.y
	
func _on_tick():
	if randf() > 0.99:
		spawn_camper()
		
func spawn_camper():
	var camper = camper_scene.instantiate()
	camper.z_index = global_position.y
	add_child(camper)

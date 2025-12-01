extends Node2D	
@onready var camp_scene: PackedScene = preload("res://level_generation/campsite.tscn")
@onready var illegal_camp_scene: PackedScene = preload("res://level_generation/illegal_campsite.tscn")

var illegal_camps: Array = []

var illegal_chance = 1.0

func _ready() -> void:
	spawn_campsites()
	var world_timer = get_tree().get_current_scene().get_node("Level/world_timer")
	world_timer.tick.connect(_on_tick)
	var weather = get_tree().get_current_scene().get_node("Level/weather_control") # node that provides sigals for diffrent weather types
	weather.relax.connect(_relax)
	weather.illegal_camper_wave.connect(_illegal_camper_wave) 

func _on_tick():
	var n = randf()
	if n*illegal_chance > 0.9999:
		spawn_illegal_campsite()

func close_camps():
	#increase illegal spawn rate
	for camp in get_parent().camps:
		camp.close_camp()

func spawn_campsites():
	for i in 2:
		spawn_campsite(i)
	
func spawn_campsite(idx : int):
	var point = get_parent().seed_points[idx]
	var camp = camp_scene.instantiate()
	camp.position = point
	add_child(camp)
	camp.source_camp = true
	get_parent().camps.append(camp)
	
func spawn_illegal_campsite():
	var camp = illegal_camp_scene.instantiate()
	var idx_range = range(5,25) # hardcoded but fine for now
	for x in illegal_camps:
		idx_range.erase(x.idx)
	if idx_range.is_empty():
		return
	var idx = idx_range.pick_random() # need to not make this manual
	var pos = get_parent().seed_points[idx]
	var near_trees = get_parent().seed_tree_groups[idx]
	illegal_camps.append(camp)
	camp.idx = idx
	camp.set_pos(pos, near_trees)
	camp.z_index = global_position.y
	camp.source_camp = false
	add_child(camp)
	
func _illegal_camper_wave():
	illegal_chance = 1.5

func _relax():
	illegal_chance = 1.0

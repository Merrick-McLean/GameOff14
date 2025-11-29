extends Node2D	
@onready var camp_scene: PackedScene = preload("res://level_generation/campsite.tscn")
@onready var illegal_camp_scene: PackedScene = preload("res://level_generation/illegal_campsite.tscn")

var illegal_camps: Array = []

func _ready() -> void:
	spawn_campsites()
	var world_timer = get_tree().get_current_scene().get_node("Level/world_timer")
	world_timer.tick.connect(_on_tick)

func _on_tick():
	var n:= randf()
	if n > 0.99:
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
	camp.z_index = point[1]
	add_child(camp)
	get_parent().camps.append(camp)
	
func spawn_illegal_campsite():
	var camp = illegal_camp_scene.instantiate()
	add_child(camp)
	var idx_range = range(4,25)
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

func remove_illegal_camp(node):
	pass

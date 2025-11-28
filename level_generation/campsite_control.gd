extends Node2D
class_name CampManager

var trees: Array = []
var campers: Array = []
var camps: Array = []
var fire_chance: float = 0.0
var open: bool = true
var source_camp = false

@export var max_campers: int = 10
@onready var camper_scene: PackedScene = preload("res://level_generation/camper.tscn")
@onready var illegal_camp_scene: PackedScene = preload("res://level_generation/illegal_campsite.tscn")


func _ready() -> void:
	var world_timer = get_tree().get_current_scene().get_node("Level/world_timer")
	world_timer.tick.connect(_on_tick)
	z_index = global_position.y
	spawn_camper()

func _on_tick() -> void:
	if campers.size() == 0:
		return  

	var n := randf()

	if n < 0.001 * campers.size():
		light_tree()

	elif n > 0.999 * (1.0 / campers.size()):
		despawn_camper()

	elif n < 0.1 and campers.size() < max_campers:
		spawn_camper()
		
		
	n = randf()
		
	if n < 0.1:
		spawn_illegal_campsite()
		
func despawn_camper() -> void:
	if campers.is_empty():
		return

	var tribute = campers.pick_random()
	if tribute.lighter:
		return

	campers.erase(tribute)
	tribute.hide()
	tribute.queue_free()

func close_camps() -> void:
	for tribute in campers:
		tribute.hide()
		tribute.queue_free()

	campers.clear()

func spawn_camper(pos = Vector2(0,0)) -> void:
	var camper = camper_scene.instantiate()
	camper.z_index = global_position.y
	add_child(camper)
	campers.append(camper)
	camper.position = pos

func light_tree() -> void:
	if campers.is_empty() or trees.is_empty():
		return
	var camper = campers.pick_random()
	var tree = trees.pick_random()
	camper.go_light(tree)
	
func spawn_illegal_campsite():
	var camp = illegal_camp_scene.instantiate()
	camp.z_index = global_position.y
	add_child(camp)
	var screen_size = get_viewport_rect().size 
	var idx_range = range(4,25)
	for x in camps:
		idx_range.erase(x.idx)
	var idx = idx_range.pick_random() # need to not make this manual
	var pos = get_parent().seed_points[idx]
	var near_trees = get_parent().seed_tree_groups[idx]
	camps.append(camp)
	camp.idx = idx
	camp.set_pos(pos, near_trees)
	
func remove_illegal_camp(node):
	camps.erase(node)

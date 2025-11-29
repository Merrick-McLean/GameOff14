extends Node2D
class_name Camp

var trees: Array = []
var campers: Array = []
var fire_chance: float = 0.0
var open: bool = true
var source_camp = false

@export var max_campers: int = 10
@onready var camper_scene: PackedScene = preload("res://level_generation/camper.tscn")


func _ready() -> void:
	var world_timer = get_tree().get_current_scene().get_node("Level/world_timer")
	world_timer.tick.connect(_on_tick)
	z_index = global_position.y
	spawn_camper()

func _on_tick() -> void:
	if campers.size() == 0:
		return  

	var n = randf()

	if n < 0.0001 * campers.size():
		light_tree()

	elif n > 0.9999 and campers.size() < max_campers and open:
		spawn_camper()

		
func despawn_camper() -> void:
	if campers.is_empty():
		return

	var tribute = campers.pick_random()
	if tribute.lighter:
		return

	campers.erase(tribute)
	tribute.hide()
	tribute.queue_free()

func close_camp() -> void:
	for tribute in campers:
		tribute.hide()
		tribute.queue_free()

	campers.clear()
	open = false

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
	

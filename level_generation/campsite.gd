extends Node2D
class_name Camp

@onready var smoke = $smoke

var trees: Array = []
var campers: Array = []
var fire_chance: float = 0.0
var open: bool = true
var source_camp = false

var camper_chance = 1.0

var revenue = 0.0

@export var max_campers: int = 10
@onready var camper_scene: PackedScene = preload("res://level_generation/camper.tscn")


func _ready() -> void:
	var world_timer = get_tree().get_current_scene().get_node("Level/world_timer")
	world_timer.tick.connect(_on_tick)
	z_index = global_position.y
	spawn_camper()
	
	var weather = get_tree().get_current_scene().get_node("Level/weather_control") # node that provides sigals for diffrent weather types
	weather.relax.connect(_relax)
	weather.camper_wave.connect(_camper_wave) 

func _on_tick() -> void:
	
	revenue += int(campers.size()/10)
	
	var n = randf()

	if n < 0.00001 * campers.size():
		light_tree()

	elif n*camper_chance > 0.9999 and campers.size() < max_campers and open:
		spawn_camper()
		
	n = randf()
	
	if n < 0.0005:
		despawn_camper()
		
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
	
	smoke.visible = false
	campers.clear()
	open = false

func spawn_camper(pos = Vector2(0,0)) -> void:
	var camper = camper_scene.instantiate()
	camper.z_index = global_position.y
	campers.append(camper)
	camper.position = pos
	add_child(camper)

func light_tree() -> void:
	if campers.is_empty() or trees.is_empty():
		return
	var camper = campers.pick_random()
	var tree = trees.pick_random()
	camper.go_light(tree)
	
func _relax():
	camper_chance = 1.5
	
func _camper_wave():
	camper_chance = 1.0
